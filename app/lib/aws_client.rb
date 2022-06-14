# frozen_string_literal: true

# AWS Client Wrapper
class AwsClient
  include AppsignalReporting

  class NoBucketFoundError < StandardError; end

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

  def find_bucket(name:)
    raise NoBucketFoundError unless @client.list_buckets.buckets.map(&:name).include?(name)

    true
  rescue StandardError => e
    # binding.pry
    send_appsignal_error(
      action: 'aws-find-bucket',
      exception: e,
      metadata: { name: name }
    )
  end

  def list_file_names(source_bucket)
    bucket_objects = find_bucket(name: source_bucket) && @client.list_objects_v2({ bucket: source_bucket }).contents
    raise NoFilesFoundError if bucket_objects.empty?

    bucket_objects.map! { |object| object[:key] }
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-list-file-names',
      exception: e,
      metadata: { source_bucket: source_bucket }
    )
  end

  def get_file_contents(source_bucket, file_name)
    contents = find_bucket(name: source_bucket) &&
               @client.get_object({ bucket: source_bucket, key: file_name }).body.read
    raise EmptyContentsError if contents.blank?

    contents
    # TODO: return entire object, csv parsers should check for object.content_type == 'text/csv'
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
    find_bucket(name: source_bucket) && find_bucket(name: archive_bucket)
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
    find_bucket(name: archive_bucket)
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
