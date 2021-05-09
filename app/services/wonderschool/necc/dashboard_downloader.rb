# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # downloads Dashboard data compiled from Wonderschool, NECC and provider data
    class DashboardDownloader
      def call
        download_dashboard_exports
      end

      private

      def download_dashboard_exports
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
        if Wonderschool::Necc::DashboardProcessor.new(contents).call
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

      def date; end

      def source_bucket
        Rails.application.config.aws_necc_dashboard_bucket
      end

      def archive_bucket
        Rails.application.config.aws_necc_dashboard_archive_bucket
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

      def log(type, message)
        case type
        when 'not_found'
          Rails.logger.tagged('NECC Dashboard') { Rails.logger.info "No file found in S3 bucket #{message} at #{Time.current.strftime('%m/%d/%Y %I:%M%p')}" }
        when 'success'
          Rails.logger.tagged('NECC Dashboard') { Rails.logger.info message }
        when 'failed'
          Rails.logger.tagged('NECC Dashboard') { Rails.logger.error message }
        end
      end
    end
  end
end
