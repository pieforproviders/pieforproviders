# frozen_string_literal: true

# Not attending period uploader
class NotAttendingPeriodUploader
  include AppsignalReporting
  include CsvTypecasting

  class NotEnoughInfo < StandardError; end

  class NoSuchBusiness < StandardError; end

  class NoSuchChild < StandardError; end

  def initialize
    @client = AwsClient.new
    @source_bucket = Rails.application.config.aws_not_attending_period_bucket
    @archive_bucket = Rails.application.config.aws_not_attending_period_archive_bucket
    @output_data = []
    @upload_status = ''
  end

  def call
    process_info
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop: disable Metrics/MethodLength
  def process_info
    file_names = @client.list_file_names(@source_bucket).select { |s| s.end_with? '.csv' }
    contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
    contents.each_with_index do |body, index|
      @file_name = file_names[index]
      CsvParser.new(body).call.each do |row|
        process_row(row)
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

  def process_row(row)
    @row = row
    @child = child

    create_period
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

  def create_period
    start_date = @row['start_date']
    end_date = @row['end_date']
    return unless start_date.present? || end_date.present?

    existing_period = @child.not_attending_period
    if existing_period.present?
      existing_period.update(start_date:, end_date:)
    else
      NotAttendingPeriod.new(start_date:, end_date:, child_id: @child.id).save
    end
  end

  def child
    if @row['first_name'].blank? || @row['last_name'].blank?
      found_child = Child.find_by(dhs_id: @row['dhs_id'])
    else
      matching_engine = NameMatchingEngine.new(first_name: @row['first_name'], last_name: @row['last_name'])
      match_children = matching_engine.call
      matching_actions = NameMatchingActions.new(match_children:,
                                                 file_child: [@row['first_name'],
                                                              @row['last_name']])

      found_child = matching_actions.call
    end
    found_child.presence || log_missing_child
  end

  # rubocop:enable Metrics/AbcSize

  def log_missing_child
    @upload_status = Rainbow('Not Found').bright
    raise NoSuchChild
  end

  def print_successful_message
    @upload_status = Rainbow('Not Attending Period Uploaded Successfully').green
  end

  def should_print_message?
    !Rails.env.test?
  end
end
