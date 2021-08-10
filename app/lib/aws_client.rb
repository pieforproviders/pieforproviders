# frozen_string_literal: true

# AWS Client Wrapper
class AwsClient
  include AppsignalReporting

  class NoFilesFoundError < StandardError; end

  class EmptyContentsError < StandardError; end

  def initialize
    akid = Rails.application.config.aws_access_key_id
    secret = Rails.application.config.aws_secret_access_key
    region = Rails.application.config.aws_region
    @client = Aws::S3::Client.new(
      credentials: Aws::Credentials.new(akid, secret),
      region: region
    )
  rescue StandardError => e
    send_appsignal_error('aws-client', e.message)
  end

  def list_file_names(source_bucket)
    file_names = @client.list_objects_v2({ bucket: source_bucket })[:contents].map! { |file| file[:key] }
    raise NoFilesFoundError unless file_names
  rescue StandardError => e
    send_appsignal_error('aws-list-file-names', e.message, source_bucket)
  end

  def get_file_contents(source_bucket, file_name)
    body = @client.get_object({ bucket: source_bucket, key: file_name }).body
    raise EmptyContentsError if body.blank?
  rescue StandardError => e
    send_appsignal_error('aws-get-file-contents', e.message, [source_bucket, file_name].join(' - '))
  end

  def archive_file(source_bucket, archive_bucket, file_name)
    @client.copy_object({ bucket: archive_bucket, copy_source: "#{source_bucket}/#{file_name}", key: file_name })
    @client.delete_object({ bucket: source_bucket, key: file_name })
  rescue StandardError => e
    send_appsignal_error('aws-archive-file', e.message, [source_bucket, archive_bucket, file_name].join(' - '))
  end

  def archive_contents(archive_bucket, file_name, contents)
    @client.put_object({ bucket: archive_bucket, key: file_name, body: contents })
  rescue StandardError => e
    send_appsignal_error('aws-archive-contents', e.message, [archive_bucket, file_name, contents].join(' - '))
  end
end
