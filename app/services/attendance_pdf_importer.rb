# frozen_string_literal: true

# Self-Serve Attendance Importer

# rubocop:disable Metrics/ClassLength
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
    @output_data = []
    @upload_status = ''
  end

  def call
    read_attendances
  end

  private

  def retrieve_file_names
    @client.list_file_names(@source_bucket, 'PDF/').select { |s| s.end_with? '.pdf' }
  end

  def read_attendances
    file_names = retrieve_file_names
    contents = file_names.map { |file_name| @client.get_xlsx_contents(@source_bucket, file_name) }

    contents.each_with_index do |content, index|
      @file_name = file_names[index]
      process_contents(content)
      process_data
      build_output_rows
    end

    file_names.each { |file| @client.archive_file(@source_bucket, @archive_bucket, file) }

    print_report_table
  end

  def print_report_table
    table = Terminal::Table.new headings: %w[Child Status File_Name], rows: @output_data
    # rubocop:disable Rails/Output
    puts table
    # rubocop:enable Rails/Output
  end

  def build_output_rows
    new_row = ["#{@child_name[1]} #{@child_name[0]}", @upload_status, @file_name]
    @output_data << new_row unless @output_data.include? new_row
  end

  def process_contents(content)
    attendance_reader = Commands::Attendance::ParsePdf.new(content)
    @attendance_data = attendance_reader.call
    business_name = attendance_reader.business
    @child_name = attendance_reader.child
    @business = business(business_name)
  end

  # rubocop: disable Metrics/AbcSize
  def process_data
    @child = child
    process_attendances

    print_successful_message if should_print_message?
  rescue StandardError => e
    @upload_status = e.message.include?('NoSuchChild') ? Rainbow(e.message).bright : Rainbow(e.message).red
    # rubocop:disable Rails/Output
    puts Rainbow("Error on child #{@child_name[1]} #{@child_name[0]}. error => #{e.message}").red
    # rubocop:enable Rails/Output
    send_appsignal_error(
      action: 'self-serve-attendance-csv-importer',
      exception: e,
      namespace: e.instance_of?(NoSuchChild) ? 'customer-support' : nil,
      tags: { child_id: @child&.id }
    )
  end
  # rubocop:enable Metrics/AbcSize

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

    child_approval = active_child_approval(check_in:)

    attendance = Attendance.find_by(check_in:, child_approval:, check_out:)

    return if attendance

    Commands::Attendance::Create.new(check_in:, child_id: @child.id, check_out:).create
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
    matching_engine = NameMatchingEngine.new(first_name: @child_name[1], last_name: @child_name[0])
    match_children = matching_engine.call

    matching_actions = NameMatchingActions.new(match_children:,
                                               file_child: [@child_name[1],
                                                            @child_name[0]])

    found_child = matching_actions.call

    found_child.presence || log_missing_child
  end

  def log_missing_child
    raise NoSuchChild
  end

  def log_missing_business
    message = Rainbow("Business #{@file_name.split('-').first} not found; skipping").red
    Rails.logger.tagged('attendance import') do
      Rails.logger.info message
    end
    # rubocop:disable Rails/Output
    puts message
    # rubocop:enable Rails/Output
    raise NoSuchBusiness
  end

  def print_successful_message
    @upload_status = Rainbow('Uploaded Successfully').green
  end

  def should_print_message?
    !Rails.env.test?
  end
end

# rubocop:enable Metrics/ClassLength
