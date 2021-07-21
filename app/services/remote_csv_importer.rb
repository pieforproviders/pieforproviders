# frozen_string_literal: true

require 'csv'
require 'open-uri'

# Service object to import and process CSVs from S3
class RemoteCsvImporter
  class EmptyCsvError < StandardError; end

  class FailedRowsError < StandardError; end

  def initialize
    akid = Rails.application.config.aws_access_key_id
    secret = Rails.application.config.aws_secret_access_key
    region = Rails.application.config.aws_region
    @client = Aws::S3::Client.new(
      credentials: Aws::Credentials.new(akid, secret),
      region: region
    )
  end

  def call
    import_and_process_csv
  end

  protected

  # subclasses must implement action, uri, archive_bucket and process_row
  def import_and_process_csv
    process_and_archive("#{Time.current}-#{action.split(' ').join('-')}", CSV.parse(contents, **csv_options))
  end

  def process_and_archive(file_name, contents)
    failed_rows = []

    raise EmptyCsvError if contents.empty?

    contents.each do |row|
      failed_rows << row unless process_row(row)
    end

    raise FailedRowsError if failed_rows.any?

    archive_file(file_name)
  rescue StandardError => e
    send_error(e)
  end

  def contents
    URI.parse(uri).open
  end

  def archive_file(file_name)
    @client.put_object({ bucket: archive_bucket, key: file_name })
  end

  def send_error(message, identifier = nil)
    Appsignal.send_error(message) do |transaction|
      transaction.set_action(action)
      transaction.params = { time: Time.current.to_s, identifier: identifier }
    end
    false
  end

  def csv_options
    {
      headers: true,
      liberal_parsing: true,
      return_headers: false,
      skip_lines: /^(,*|\s*)$/,
      unconverted_fields: %i[child_id],
      converters: %i[date]
    }
  end

  def to_float(value)
    value&.delete(',')&.to_f
  end

  def to_integer(value)
    value&.delete(',')&.to_i
  end

  def to_boolean(value)
    value == 'Yes'
  end
end
