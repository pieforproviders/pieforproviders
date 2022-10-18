# frozen_string_literal: true

# Holidays CSV Importer
class HolidaysImporter
  include AppsignalReporting
  include CsvTypecasting

  class NotEnoughInfo < StandardError; end
  class NoFilesFound < StandardError; end

  def initialize
    @client = AwsClient.new
    @source_bucket = Rails.application.config.aws_onboarding_bucket
    @archive_bucket = Rails.application.config.aws_onboarding_archive_bucket
  end

  def call
    process_holidays
  end

  private

  def retrieve_file_names
    @client.list_file_names(@source_bucket, 'holidays/').select { |s| s.ends_with? '.csv' }
  end

  def process_holidays
    file_names = retrieve_file_names
    raise NoFilesFound, @source_bucket unless file_names

    contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
    contents.each do |body|
      parsed_csv = CsvParser.new(body).call
      parsed_csv.each { |row| process_row(row) }
    end
    file_names.each { |file_name| @client.archive_file(@source_bucket, @archive_bucket, file_name) }
  rescue StandardError => e
    send_appsignal_error(
      action: 'holidays-importer',
      exception: e,
      tags: { source_bucket: @source_bucket }
    )
  end

  def process_row(row)
    @row = row
    Holiday.find_or_create_by(required_holiday_params)
  rescue StandardError => e
    send_appsignal_error(
      action: 'holidays-importer',
      exception: e,
      tags: { provider: @row['Holiday'] }
    )
  end

  def required_holiday_params
    {
      name: @row['Holiday'],
      date: @row['Date']
    }
  end
end
