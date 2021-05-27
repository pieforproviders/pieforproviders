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
        contents ||= csv_contents
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

      def csv_contents
        return false if @input.is_a?(Pathname) && !File.exist?(@input)

        contents = @input.is_a?(Pathname) ? File.read(@input.to_s) : @input
        parse_contents(contents)
      end

      def parse_contents(contents)
        CSV.parse(
          contents,
          headers: true,
          liberal_parsing: true,
          return_headers: false,
          skip_lines: /^(,*|\s*)$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        )
      end

      def process_dashboard_case(row)
        child = Child.find_by(full_name: row['Child Name'], business: Business.find_by(name: row['Business']))
        return false unless child

        dashboard_case = TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child)
        dashboard_case.update!(field_mapping(row))

        true
      rescue ActiveRecord::RecordInvalid => e
        log('error processing', e)
        false
      end

      # rubocop:disable Metrics/MethodLength
      def field_mapping(row)
        {
          as_of: row['As of Date'],
          attendance_risk: row['Status'],
          absences: row['Absences'],
          earned_revenue: row['Earned revenue'],
          estimated_revenue: row['Estimated Revenue'],
          family_fee: row['Family Fee'],
          full_days: row['Full Days'],
          hours: row['Hourly'],
          hours_attended: row['Hours Attended']
        }
      end
      # rubocop:enable Metrics/MethodLength

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
    end
  end
end
