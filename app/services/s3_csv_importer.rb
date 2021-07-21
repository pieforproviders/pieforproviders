# frozen_string_literal: true

require 'csv'

# Service object to import and process CSVs from S3
class S3CsvImporter < RemoteCsvImporter
  class NoFilesFoundError < StandardError; end

  class EmptyCsvError < StandardError; end

  class FailedRowsError < StandardError; end

  protected

  # subclasses must implement action, source_bucket, archive_bucket and process_row
  def import_and_process_csv
    file_names = @client.list_objects_v2({ bucket: source_bucket })[:contents].map! { |file| file[:key] }

    raise NoFilesFoundError if file_names.empty?

    file_names.each do |file_name|
      process_and_archive(file_name, CSV.parse(contents(file_name), **csv_options))
    end
  end

  def contents(file_name)
    @client.get_object({ bucket: source_bucket, key: file_name }).body
  end

  def archive_file(file_name)
    @client.copy_object({ bucket: archive_bucket, copy_source: "#{source_bucket}/#{file_name}", key: file_name })
    @client.delete_object({ bucket: source_bucket, key: file_name })
  end
end
