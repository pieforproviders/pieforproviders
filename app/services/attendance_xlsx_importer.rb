# frozen_string_literal: true

# Self-Serve Attendance Importer

# rubocop:disable Metrics/ClassLength
class AttendanceXlsxImporter
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
    @client.list_file_names(@source_bucket, 'XLSX/').select { |s| s.end_with? '.xlsx' }
  end

  def read_attendances
    @attendance_data = []
    file_names = retrieve_file_names
    contents = file_names.map { |file_name| @client.get_xlsx_contents(@source_bucket, file_name) }
    process_contents(contents, file_names)

    @attendance_data.flatten.each { |child_data| process_data(child_data) }

    file_names.each { |file| @client.archive_file(@source_bucket, @archive_bucket, file) }
  end

  def process_contents(contents, file_names)
    contents.each_with_index do |data, index|
      @file_name = file_names[index]
      @business = business
      attendance_reader = XlsxAttendanceReader.new(data)
      @attendance_data << attendance_reader.process
    end
  end

  def process_data(child_data)
    @child_attendances = {}
    strip_children_data(child_data)

    process_attendances

    print_successful_message unless Rails.env.test?
  rescue StandardError => e
    # rubocop:disable Rails/Output
    puts Rainbow("Error on child #{@child_names[0]} #{@child_names[1]}. error => #{e.inspect}").red
    # rubocop:enable Rails/Output
    send_appsignal_error(
      action: 'self-serve-attendance-csv-importer',
      exception: e,
      namespace: e.instance_of?(NoSuchChild) ? 'customer-support' : nil,
      tags: { child_id: @child&.id }
    )
  end

  def process_attendances
    @child_attendances.each do |attendance|
      check_in_date_time = Time.strptime(attendance[:check_in], '%Y-%m-%d %I:%M %p')

      next unless (@start_date..@end_date).cover?(check_in_date_time.at_beginning_of_day)

      create_attendance(attendance)
    end
  end

  def strip_children_data(child_data)
    @child_attendances = child_data[:check_in_out_data]
    @child_names = [child_data[:first_name], child_data[:last_name]]
    @child = child
  end

  def create_attendance(attendance_info)
    check_in = Time.strptime(attendance_info[:check_in], '%Y-%m-%d %I:%M %p').to_datetime
    check_out = if attendance_info[:check_out].blank?
                  nil
                else
                  Time.strptime(attendance_info[:check_out], '%Y-%m-%d %I:%M %p').to_datetime
                end

    child_approval = active_child_approval(check_in: check_in)

    attendance = Attendance.find_by(check_in: check_in, child_approval: child_approval, check_out: check_out)

    return if attendance # makes the import idempotent

    Commands::Attendance::Create.new(check_in: check_in, child_id: @child.id, check_out: check_out).create
  end

  def active_child_approval(check_in:)
    @child&.approvals&.active_on(check_in)
      &.first&.child_approvals&.find_by(child: @child)
  end

  def business
    found_business = Business.find_by(name: @file_name.split('.').first.split('/').last)
    found_business.presence || log_missing_business
  end

  def child
    matching_engine = NameMatchingEngine.new(first_name: @child_names[0], last_name: @child_names[1])
    match_results = matching_engine.call

    match_tag = match_results[:match_tag]
    match_child = match_results[:result_match]

    matching_actions = NameMatchingActions.new(match_tag: match_tag,
                                               match_child: match_child,
                                               file_child: [@child_names[0],
                                                            @child_names[1]],
                                               business: @business)

    found_child = matching_actions.call

    found_child.presence || log_missing_child
  end

  def log_missing_child
    message = Rainbow("Business: #{@business.id} - child record for attendance " \
                      "not found, child #{@child_names[0]} #{@child_names[1]}; " \
                      'skipping').red
    Rails.logger.tagged('attendance import') do
      Rails.logger.info(message)
    end

    # rubocop:disable Rails/Output
    puts message
    # rubocop:enable Rails/Output

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
    # rubocop:disable Rails/Output
    puts Rainbow("DHS ID: #{@child.dhs_id} has been successfully processed").green
    # rubocop:enable Rails/Output
  end
end

# rubocop:enable Metrics/ClassLength
