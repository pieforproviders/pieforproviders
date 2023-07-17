# frozen_string_literal: true

# Self-Serve Attendance Importer
class AttendancePdfImporter
  include AppsignalReporting

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
    read_attendances
  end

  private

  def retrieve_file_names
    @client.list_file_names(@source_bucket, 'PDF/').select { |s| s.end_with? '.pdf' }
  end

  def read_attendances
    @attendance_data = []
    file_names = retrieve_file_names
    contents = file_names.map { |file_name| @client.get_xlsx_contents(@source_bucket, file_name) }

    process_contents(contents, file_names)

    process_data

    file_names.each { |file| @client.archive_file(@source_bucket, @archive_bucket, file) }
  end

  def process_contents(contents, file_names)
    contents.each_with_index do |data, index|
      @file_name = file_names[index]
      attendance_reader = Commands::Attendance::ParsePdf.new(data)
      @attendance_data << attendance_reader.call
      business_name = attendance_reader.business
      @child_name = attendance_reader.child
      @business = business(business_name)
      @child = child
    end
  end

  def process_data
    process_attendances

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

  def process_attendances
    @attendance_data.flatten.each do |attendance|
      next if attendance[:sign_in_time].blank?

      check_in_date_time = attendance[:sign_in_time].to_datetime

      next unless (@start_date..@end_date).cover?(check_in_date_time.at_beginning_of_day)

      create_attendance(attendance)
    end
  end

  def create_attendance(attendance_info)
    check_in = attendance_info[:sign_in_time].to_datetime
    check_out = attendance_info[:sign_out_time].blank? ? nil : attendance_info[:sign_out_time].to_datetime

    child_approval = active_child_approval(check_in: check_in)

    attendance = Attendance.find_by(check_in: check_in, child_approval: child_approval, check_out: check_out)

    return if attendance

    Commands::Attendance::Create.new(check_in: check_in, child_id: @child.id, check_out: check_out).create
  end

  def active_child_approval(check_in:)
    @child&.approvals&.active_on(check_in)
      &.first
      &.child_approvals
      &.find_by(child: @child)
  end

  def business(business_name)
    found_business = Business.find_by(name: business_name)
    found_business.presence || log_missing_business
  end

  def child
    found_child = @business.children.find_by(
      first_name: @child_name[1], last_name: @child_name[0]
    )
    found_child.presence || log_missing_child
  end

  def log_missing_child
    message = "Business: #{@business.id} - child record for attendance " \
              "not found (dhs_id: #{@child['dhs_id']}, ); skipping"

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
    pp "DHS ID: #{@child.dhs_id} has been successfully processed"
    # rubocop:enable Rails/Output
  end

  def should_print_message?
    !Rails.env.test?
  end
end
