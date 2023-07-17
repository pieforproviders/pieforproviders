# frozen_string_literal: true

# Self-Serve Attendance Importer
class AttendanceCsvImporter
  include AppsignalReporting
  include CsvTypecasting

  class NotEnoughInfo < StandardError; end

  class NoSuchBusiness < StandardError; end

  class NoSuchChild < StandardError; end

  def initialize(start_date: nil, end_date: 0.days.after)
    @client = AwsClient.new
    @source_bucket = Rails.application.config.aws_necc_attendance_bucket
    @archive_bucket = Rails.application.config.aws_necc_attendance_archive_bucket
    @start_date = start_date&.at_beginning_of_day
    @end_date = end_date&.at_end_of_day
  end

  def call
    process_attendances
  end

  private

  def process_attendances
    file_names = @client.list_file_names(@source_bucket).select { |s| s.end_with? '.csv' }
    contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
    contents.each_with_index do |body, index|
      @file_name = file_names[index]
      @business = business
      CsvParser.new(body).call.each { |unstriped_row| process_row(unstriped_row) }
    end
    file_names.each do |file_name|
      @client.archive_file(@source_bucket, @archive_bucket, file_name, "#{Time.current}-#{file_name}")
    end
  end

  def process_row(unstriped_row)
    @row = {}
    strip_row(unstriped_row)
    return unless (@start_date..@end_date).cover?(@row['check_in'].in_time_zone(@child.timezone).at_beginning_of_day)

    create_attendance
    print_successful_message if should_print_message?
  rescue StandardError => e
    # rubocop:disable Rails/Output
    pp "Error on child #{@child.inspect}. error => #{e.inspect}"
    # rubocop:enable Rails/Output
    send_appsignal_error(
      action: 'self-serve-attendance-csv-importer',
      exception: e,
      namespace: e.instance_of?(NoSuchChild) ? 'customer-support' : nil,
      tags: { child_id: @child&.id }
    )
  end

  def strip_row(unstriped_row)
    unstriped_row.each { |k, value| @row[k] = value.to_s.strip }
    @row['absence'] = unstriped_row['absence']
    @child = child
  end

  def create_attendance
    check_in = format_check_in_out(@row['check_in'])
    check_out = @row['check_out'].blank? ? nil : format_check_in_out(@row['check_out'])
    if @row['absence']
      find_or_create_service_day(check_in: check_in)
    else
      child_approval = active_child_approval(check_in: check_in)
      attendance = Attendance.find_by(check_in: check_in, child_approval: child_approval, check_out: check_out)
      return if attendance # makes the import idempotent

      Commands::Attendance::Create.new(check_in: check_in, child_id: @child.id, check_out: check_out).create
    end
  end

  def format_check_in_out(date_time)
    date_time.to_datetime.strftime('%Y-%m-%d %H:%M:%S').to_datetime
  end

  def active_child_approval(check_in:)
    @child
      &.approvals&.active_on(check_in)
      &.first&.child_approvals
      &.find_by(child: @child)
  end

  def find_or_create_service_day(check_in:)
    service_day = ServiceDay.find_or_create_by!(
      child: @child,
      date: check_in.strftime('%Y-%m-%d %H:%M:%S').to_datetime.at_beginning_of_day
    )
    service_day.update!(absence_type: @row['absence'])
  end

  def business
    found_business = Business.find_by(name: @file_name.split('.').first.split('-'))

    found_business.presence || log_missing_business
  end

  def child
    found_child = @business.children.find_by(dhs_id: @row['dhs_id']) || @business.children.find_by(
      first_name: @row['first_name'], last_name: @row['last_name']
    )

    found_child.presence || log_missing_child
  end

  def log_missing_child
    message = "Business: #{@business.id} - child record for attendance " \
              "not found (dhs_id: #{@row['dhs_id']}, check_in: #{@row['check_in']}, " \
              "check_out: #{@row['check_out']}, absence: #{@row['absence']}); skipping"
    Rails.logger.tagged('attendance import') do
      Rails.logger.info message
    end

    # rubocop:disable Rails/Output
    pp message
    # rubocop:enable Rails/Output

    raise NoSuchChild
  end

  def log_missing_business
    message = "Business #{@file_name.split('-').first} not found; skipping"
    Rails.logger.tagged('attendance import') do
      Rails.logger.info message
    end

    # rubocop:disable Rails/Output
    pp message
    # rubocop:enable Rails/Output

    raise NoSuchBusiness
  end

  def print_successful_message
    # rubocop:disable Rails/Output
    pp "DHS ID: #{@row['dhs_id']} has been successfully processed"
    # rubocop:enable Rails/Output
  end

  def should_print_message?
    !Rails.env.test?
  end
end
