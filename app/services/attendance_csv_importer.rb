# frozen_string_literal: true

# Self-Serve Attendance Importer
class AttendanceCsvImporter
  include AppsignalReporting
  include CsvTypecasting

  class NotEnoughInfo < StandardError; end

  class NoSuchBusiness < StandardError; end

  class NoSuchChild < StandardError; end

  def initialize
    @client = AwsClient.new
    @source_bucket = Rails.application.config.aws_necc_attendance_bucket
    @archive_bucket = Rails.application.config.aws_necc_attendance_archive_bucket
  end

  def call
    process_attendances
  end

  private

  def process_attendances
    file_names = @client.list_file_names(@source_bucket)
    contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
    contents.each_with_index do |body, index|
      parsed_csv = CsvParser.new(body).call
      parsed_csv.each { |row| process_row(row, file_names[index]) }
    end
    file_names.each do |file_name|
      @client.archive_file(@source_bucket, @archive_bucket, "#{Time.current}-#{file_name}")
    end
  end

  def process_row(row, file_name)
    @file_name = file_name
    @row = row
    @business = business
    @child = child

    create_attendance
  rescue StandardError => e
    send_appsignal_error(
      action: 'self-serve-attendance-csv-importer',
      exception: e,
      namespace: e.instance_of?(NoSuchChild) ? 'customer-support' : nil,
      metadata: { child_id: @child&.id }
    )
  end

  def create_attendance
    check_in = @row['check_in'].in_time_zone(child.timezone)
    check_out = @row['check_out']&.in_time_zone(child.timezone)

    if @row['absence']
      find_or_create_service_day(check_in: check_in)
    else
      child_approval = active_child_approval(check_in: check_in)
      attendance = Attendance.find_by(check_in: check_in, child_approval: child_approval, check_out: check_out)
      return if attendance # makes the import idempotent

      Commands::Attendance::Create.new(check_in: check_in, child_id: @child.id, check_out: check_out).create
    end
  end

  def active_child_approval(check_in:)
    @child
      &.approvals
      &.active_on(check_in)
      &.first
      &.child_approvals
      &.find_by(child: @child)
  end

  def find_or_create_service_day(check_in:)
    service_day = ServiceDay.find_or_create_by!(child: @child, date: check_in.at_beginning_of_day)
    service_day.update!(absence_type: @row['absence'])
  end

  def business
    found_business = Business.find_by(name: @file_name.split('-').first)

    found_business.presence || log_missing_business
  end

  def child
    found_child = @business.children.find_by(dhs_id: @row['dhs_id']) || @business.children.find_by(
      first_name: @row['first_name'], last_name: @row['last_name']
    )
    found_child.presence || log_missing_child
  end

  def log_missing_child
    Rails.logger.tagged('attendance import') do
      message = "Business: #{@business.id} - child record for attendance "\
                "not found (dhs_id: #{@row['dhs_id']}, check_in: #{@row['check_in']}, "\
                "check_out: #{@row['check_out']}, absence: #{@row['absence']}); skipping"
      Rails.logger.info message
    end
    raise NoSuchChild
  end

  def log_missing_business
    Rails.logger.tagged('attendance import') do
      Rails.logger.info "Business #{@file_name.split('-').first} not found; skipping"
    end
    raise NoSuchBusiness
  end
end
