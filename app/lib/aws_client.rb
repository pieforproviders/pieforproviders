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
    send_appsignal_error(action: 'aws-client', exception: e)
  end

  def list_file_names(source_bucket)
    file_names = @client.list_objects_v2({ bucket: source_bucket })
    raise NoFilesFoundError if file_names.empty?

    file_names[:contents].map! { |file| file[:key] }
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-list-file-names',
      exception: e,
      metadata: { source_bucket: source_bucket }
    )
  end

  def get_file_contents(source_bucket, file_name)
    object = @client.get_object({ bucket: source_bucket, key: file_name })
    raise EmptyContentsError if object.blank?

    object.body
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-get-file-contents',
      exception: e,
      metadata: {
        source_bucket: source_bucket,
        file_name: file_name
      }
    )
  end

  def archive_file(source_bucket, archive_bucket, file_name)
    @client.copy_object({ bucket: archive_bucket, copy_source: "#{source_bucket}/#{file_name}", key: file_name })
    @client.delete_object({ bucket: source_bucket, key: file_name })
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-archive-file',
      exception: e,
      metadata: {
        source_bucket: source_bucket,
        archive_bucket: archive_bucket,
        file_name: file_name
      }
    )
  end

  def archive_contents(archive_bucket, file_name, contents)
    @client.put_object({ bucket: archive_bucket, key: file_name, body: contents })
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-archive-contents',
      exception: e,
      metadata: {
        archive_bucket: archive_bucket,
        file_name: file_name
      }
    )
  end
end
