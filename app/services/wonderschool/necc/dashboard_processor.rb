# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # processes Dashboard data compiled from Wonderschool, NECC and provider data
    class DashboardProcessor
      def initialize(input)
        @input = input
        @storage_client = Aws::S3::Client.new(
          credentials: Aws::Credentials.new(akid, secret),
          region: region
        )
      end

      def call
        read_contents
      end

      private

      def read_contents
        contents = convert_by_type

        log('blank_contents', @input.to_s) and return false if contents.blank?

        failed_dashboard_cases = []
        contents.each { |row| process_dashboard_case(row) || failed_dashboard_cases << row }

        if failed_dashboard_cases.present?
          log('failed_dashboard_cases', failed_dashboard_cases.flatten.to_s)
          store('failed_dashboard_cases', failed_dashboard_cases.flatten.to_s)
          return false
        end
        contents.to_s
      end

      def convert_by_type
        if [String, StringIO].member?(@input.class)
          parse_string_to_csv
        elsif File.file?(@input.to_s)
          read_csv_file
        end
      end

      def log(type, message)
        case type
        when 'blank_contents'
          Rails.logger.tagged('NECC Dashboard file cannot be processed') { Rails.logger.error message }
        when 'failed_dashboard_cases'
          Rails.logger.tagged('NECC Dashboard cases failed to process') { Rails.logger.error message }
        end
      end

      def store(file_name, data)
        @storage_client.put_object({ bucket: archive_bucket, body: data, key: file_name })
      end

      def read_csv_file
        CSV.read(@input,
                 headers: true,
                 return_headers: false,
                 unconverted_fields: %i[child_id],
                 converters: %i[date])
      end

      def parse_string_to_csv
        CSV.parse(@input,
                  headers: true,
                  return_headers: false,
                  unconverted_fields: %i[child_id],
                  converters: %i[date])
      end

      def process_dashboard_case(row)
        child = Child.find_by(full_name: row['Child Name'])
        return false unless child

        params = field_mapping(row)
        dashboard_case = TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child)
        unless dashboard_case.update!(params)
          log('error processing', dashboard_case.errors.to_s)
          return false
        end

        true
      end

      def field_mapping(row)
        {
          as_of: row['As of Date'],
          attendance_risk: row['Status'],
          absences: row['Absences'],
          earned_revenue: row['Earned revenue'],
          estimated_revenue: row['Estimated Revenue'],
          full_days: row['Full Days'],
          hours: row['Hourly'],
          transportation_revenue: row['Transportation revenue']
        }
      end

      def archive_bucket
        ENV.fetch('AWS_NECC_DASHBOARD_ARCHIVE_BUCKET', '')
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
    end
  end
end
