# frozen_string_literal: true

# Self-Serve Attendance Importer
class AttendanceCsvImporter
  include AppsignalReporting
  include CsvTypecasting

  class NotEnoughInfo < StandardError; end

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

  # rubocop:disable Metrics/MethodLength
  def process_row(row, file_name)
    unless (business = Business.find_by(name: file_name.split('-').first))
      log_missing_business(file_name.split('-').first)
      return
    end

    unless (child = find_child(business, row))
      log_missing_child(business.id, row['check_in'], row['check_out'], row['absence'], row['dhs_id'])
      return
    end

    create_attendance(row, child)
  rescue StandardError => e
    send_appsignal_error(
      action: 'self-serve-attendance-csv-importer',
      exception: e,
      metadata: { child_id: child&.id }
    )
  end
  # rubocop:enable Metrics/MethodLength

  def create_attendance(row, child)
    check_in = row['check_in'].in_time_zone(child.timezone)
    check_out = row['check_out']&.in_time_zone(child.timezone)

    if row['absence']
      find_or_create_service_day(row: row, child: child, check_in: check_in)
    else
      child_approval = active_child_approval(check_in: check_in, child: child)
      attendance = Attendance.find_by(check_in: check_in, child_approval: child_approval, check_out: check_out)
      return if attendance # makes the import idempotent

      Commands::Attendance::Create.new(check_in: check_in, child_id: child.id, check_out: check_out).create
    end
  end

  def active_child_approval(check_in:, child:)
    child
      &.approvals
      &.active_on(check_in)
      &.first
      &.child_approvals
      &.find_by(child: child)
  end

  def find_or_create_service_day(row:, child:, check_in:)
    service_day = ServiceDay.find_or_create_by!(child: child, date: check_in.at_beginning_of_day)
    service_day.update!(absence_type: row['absence'])
  end

  def find_child(business, row)
    business.children.find_by(dhs_id: row['dhs_id']) ||
      business.children.find_by(first_name: row['first_name'], last_name: row['last_name'])
  end

  def log_missing_child(id, check_in, check_out, absence, dhs_id)
    Rails.logger.tagged('attendance import') do
      message = "Business: #{id} - child record for attendance "\
                "not found (dhs_id: #{dhs_id}, check_in: #{check_in}, "\
                "check_out: #{check_out}, absence: #{absence}); skipping"
      Rails.logger.info message
    end
  end

  def log_missing_business(name)
    Rails.logger.tagged('attendance import') do
      Rails.logger.info "Business #{name} not found; skipping"
    end
  end
end
