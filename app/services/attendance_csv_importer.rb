# frozen_string_literal: true

# Self-Serve Attendance Importer

# rubocop:disable Metrics/ClassLength
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
    @output_data = []
    @upload_status = ''
  end

  def call
    process_attendances
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop: disable Metrics/MethodLength
  def process_attendances
    file_names = @client.list_file_names(@source_bucket, 'CSV/').select { |s| s.end_with? '.csv' }
    contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
    @previous_child = ''
    @last_found_child = nil
    contents.each_with_index do |body, index|
      @file_name = file_names[index]
      CsvParser.new(body).call.each do |unstriped_row|
        process_row(unstriped_row)
        build_output_rows
      end
    end
    file_names.each do |file_name|
      @client.archive_file(@source_bucket, @archive_bucket, file_name, "#{Time.current}-#{file_name}")
    end
    print_report_table
  end
  # rubocop: enable Metrics/MethodLength

  def build_output_rows
    new_row = ["#{@row['first_name']} #{@row['last_name']}", @upload_status, @file_name]
    @output_data << new_row unless @output_data.include? new_row
  end

  def print_report_table
    table = Terminal::Table.new headings: %w[Child Status File_Name], rows: @output_data
    # rubocop:disable Rails/Output
    puts table
    # rubocop:enable Rails/Output
  end

  def process_row(unstriped_row)
    @row = {}
    strip_row(unstriped_row)
    return unless (@start_date..@end_date).cover?(@row['check_in'].in_time_zone(@child.timezone).at_beginning_of_day)

    create_attendance
    print_successful_message if should_print_message?
  rescue StandardError => e
    @upload_status = e.message.include?('NoSuchChild') ? Rainbow(e.message).bright : Rainbow(e.message).red
    # rubocop:disable Rails/Output
    puts Rainbow("Error on child #{@row['first_name']} #{@row['last_name']}. error => #{e.message}").red
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
      find_or_create_service_day(check_in:)
    else
      child_approval = active_child_approval(check_in:)
      attendance = Attendance.find_by(check_in:, child_approval:, check_out:)
      return if attendance # makes the import idempotent

      Commands::Attendance::Create.new(check_in:, child_id: @child.id, check_out:).create
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

  def child # rubocop:disable Metrics/MethodLength
    if @row['first_name'].blank? || @row['last_name'].blank?
      found_child = Child.find_by(dhs_id: @row['dhs_id'])
    elsif @previous_child == "#{@row['first_name']} #{@row['last_name']}"
      found_child = @last_found_child
    else
      matching_engine = NameMatchingEngine.new(first_name: @row['first_name'], last_name: @row['last_name'])
      match_children = matching_engine.call

      matching_actions = NameMatchingActions.new(match_children:,
                                                 file_child: [@row['first_name'],
                                                              @row['last_name']])

      found_child = matching_actions.call
    end
    @previous_child = "#{@row['first_name']} #{@row['last_name']}"
    @last_found_child = found_child
    found_child.presence || log_missing_child
  end

  # rubocop:enable Metrics/AbcSize

  def log_missing_child
    @upload_status = Rainbow('Not Found').bright
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
