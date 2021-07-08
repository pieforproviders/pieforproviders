# frozen_string_literal: true

# Service object to import and process CSVs from S3
class S3CsvImporter
  class NoFilesFoundError < StandardError; end
  
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

  # subclasses must implement source_bucket and process_file
  def import_and_process_csv
    file_names = @client.list_objects_v2({ bucket: source_bucket })[:contents].map! { |file| file[:key] }

    raise NoFilesFoundError if file_names.empty?

    file_names.each do |file_name|
      process_file(csv(file_name))
    end
  end

  def csv(file_name)
    @client.get_object({ bucket: source_bucket, key: file_name }).body
  end
end