# frozen_string_literal: true

# AWS Client Wrapper
class AwsClient
  include AppsignalReporting

  class NoBucketFound < StandardError; end

  class NoFilesFound < StandardError; end

  class EmptyContents < StandardError; end

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

  def find_bucket(name:, tech_only: false)
    raise NoBucketFound unless @client.list_buckets.buckets.map(&:name).include?(name)

    true
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-find-bucket',
      exception: e,
      namespace: tech_only ? 'tech-support' : nil,
      tags: { name: name }
    )
  end

  def list_file_names(source_bucket, prefix = '')
    bucket_objects = find_bucket(name: source_bucket) && @client.list_objects_v2({ bucket: source_bucket,
                                                                                   prefix: prefix }).contents
    raise NoFilesFound if bucket_objects.empty?

    bucket_objects.map! { |object| object[:key] }
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-list-file-names',
      exception: e,
      tags: { source_bucket: source_bucket }
    )
  end

  def get_xlsx_contents(source_bucket, file_name)
    data_object = @client.get_object(bucket: source_bucket, key: file_name)
    data_object.body.read
  end

  def get_file_contents(source_bucket, file_name)
    contents = find_bucket(name: source_bucket) &&
               @client.get_object({ bucket: source_bucket, key: file_name }).body.read
    raise EmptyContents if contents.blank?

    contents
    # TODO: return entire object, csv parsers should check for object.content_type == 'text/csv'
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-get-file-contents',
      exception: e,
      tags: {
        source_bucket: source_bucket,
        file_name: file_name
      }
    )
  end

  def archive_file(source_bucket, archive_bucket, file_name, archive_file_name = nil)
    find_bucket(name: source_bucket) && find_bucket(name: archive_bucket, tech_only: true)
    @client.copy_object({ bucket: archive_bucket,
                          copy_source: "#{source_bucket}/#{file_name}",
                          key: (archive_file_name.presence || file_name) })
    @client.delete_object({ bucket: source_bucket, key: file_name })
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-archive-file',
      exception: e,
      namespace: 'tech-support',
      tags: {
        source_bucket: source_bucket,
        archive_bucket: archive_bucket,
        file_name: file_name
      }
    )
  end

  def archive_contents(archive_bucket, file_name, contents)
    find_bucket(name: archive_bucket, tech_only: true)
    @client.put_object({ bucket: archive_bucket, key: file_name, body: contents.to_s })
  rescue StandardError => e
    send_appsignal_error(
      action: 'aws-archive-contents',
      exception: e,
      namespace: 'tech-support',
      tags: {
        archive_bucket: archive_bucket,
        file_name: file_name
      }
    )
  end
end
