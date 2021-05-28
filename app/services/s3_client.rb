class S3Client < ApplicationService
  def initialize
    akid = Rails.application.config.aws_access_key_id
    secret = Rails.application.config.aws_secret_access_key
    region = Rails.application.config.aws_region
    @client = Aws::S3::Client.new(
      credentials: Aws::Credentials.new(akid, secret),
      region: region
    )
  end

  def list_objects(source_bucket)
    binding.pry
    @client.list_objects_v2({ bucket: source_bucket }).contents.map! { |file| file.key }
  end

  def get_object(source_bucket, file_name)
    @client.get_object({ bucket: source_bucket, key: file_name })
  end

  def archive_file(file_name, source_bucket, archive_bucket)
    if @client.copy_object({
                             bucket: archive_bucket,
                             copy_source: "#{source_bucket}/#{file_name}",
                             key: file_name
                           })
      @client.delete_object({ bucket: source_bucket, key: file_name })
    end
  end

  def write_to_archive(file_name, data, archive_bucket)
    @client.put_object({ bucket: archive_bucket, body: data, key: file_name })
  end
end
