# frozen_string_literal: true

    class S3DownloaderBase
      def initialize()
        @client = Aws::S3::Client.new(
          credentials: Aws::Credentials.new(akid, secret),
          region: region
        )
      end

      def call
        download_and_process_files
      end

      private

      def process_file
        raise 'not implemented error'

      def download_and_process_files
        file_names = @client.list_objects_v2({ bucket: source_bucket })[:contents].map! { |file| file[:key] }

        return log(:error, "not_found: #{source_bucket}") if file_names.empty?

        file_names.each do |file_name|
          process_file(file_name)
        end
      end

      def move_to_archive(file_name)
        @client.copy_object({ bucket: archive_bucket, copy_source: "#{source_bucket}/#{file_name}", key: file_name })
        #TODO: only delete if the copy succeeded.
        @client.delete_object({ bucket: source_bucket, key: file_name })
      end

      def store_in_archive(file_name, data)
        @client.put_object({ bucket: archive_bucket, body: data, key: file_name })
      end

      def date
        Time.current
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

      def source_bucket
        raise 'not implemented error'
      end

      def archive_bucket
        raise 'not implemented error'
      end

      def log(level, message)
        Rails.logger.tagged(@logger_tag) { Rails.logger.method(level).call message }
      end

    end
  end
end
