# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # downloads Onboarding CSVs compiled from Wonderschool, NECC and provider data
    class OnboardingDownloader
      def call
        download_onboarding_csv
      end

      private

      def download_onboarding_csv
        client = Aws::S3::Client.new(
          credentials: Aws::Credentials.new(akid, secret),
          region: region
        )

        file_names = client.list_objects_v2({ bucket: source_bucket })[:contents].map! { |file| file[:key] }

        return log('not_found', source_bucket) if file_names.empty?

        file_names.each do |file_name|
          process_file(client, file_name)
        end
      end

      def process_file(client, file_name)
        contents = client.get_object({ bucket: source_bucket, key: file_name }).body
        if Wonderschool::Necc::OnboardingProcessor.new(contents).call
          log('success', file_name)
          archive(client, file_name)
        else
          log('failed', file_name)
        end
      end

      def archive(client, file_name)
        client.copy_object({ bucket: archive_bucket, copy_source: "#{source_bucket}/#{file_name}", key: file_name })
        client.delete_object({ bucket: source_bucket, key: file_name })
      end

      def source_bucket
        ENV.fetch('AWS_NECC_ONBOARDING_BUCKET', '')
      end

      def archive_bucket
        ENV.fetch('AWS_NECC_ONBOARDING_ARCHIVE_BUCKET', '')
      end

      def akid
        ENV.fetch('AWS_ACCESS_KEY_ID', '')
      end

      def secret
        ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
      end

      def region
        ENV.fetch('AWS_REGION', '')
      end

      def log(type, message)
        case type
        when 'not_found'
          Rails.logger.tagged('NECC Onboarding') { Rails.logger.info "No file found in S3 bucket #{message} at #{Time.current.strftime('%m/%d/%Y %I:%M%p')}" }
        when 'success'
          Rails.logger.tagged('NECC Onboarding') { Rails.logger.info message }
        when 'failed'
          Rails.logger.tagged('NECC Onboarding') { Rails.logger.error message }
        end
      end
    end
  end
end
