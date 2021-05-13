# frozen_string_literal: true

require 'csv'
class BucketCreator
  def call
    create_buckets
  end

  private

  def create_buckets
    client = Aws::S3::Client.new(
      credentials: Aws::Credentials.new(akid, secret),
      region: region
    )
    create_bucket(client, Rails.application.config.aws_necc_attendance_bucket)
    create_bucket(client, Rails.application.config.aws_necc_attendance_archive_bucket)
    create_bucket(client, Rails.application.config.aws_necc_dashboard_bucket)
    create_bucket(client, Rails.application.config.aws_necc_dashboard_archive_bucket)
    create_bucket(client, Rails.application.config.aws_necc_onboarding_bucket)
    create_bucket(client, Rails.application.config.aws_necc_onboarding_archive_bucket)

  end

  def create_bucket(client, bucket_name)
    client.create_bucket({
      bucket: bucket_name,
      create_bucket_configuration: {
        location_constraint: region,
      },
    })
  end

  def akid
    Rails.application.config.aws_access_key_id
  end

  def secret
    Rails.application.config.aws_secret_access_key
  end

  def region
    Rails.application.config.aws_region
  end
end
