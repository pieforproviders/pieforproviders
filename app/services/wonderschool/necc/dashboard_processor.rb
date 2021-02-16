# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # processes Dashboard data exported from Wonderschool for NECC partnership
    class DashboardProcessor
      def initialize(input)
        @input = input
      end

      def call
        read_contents
      end

      private

      def read_contents
        contents = convert_by_type

        log('blank_contents', @input.to_s) and return false if contents.blank?

        failed_rows = []
        contents.each { |row| process_dashboard_case(row) || failed_rows << row }

        if failed_rows.present?
          log('failed_rows', failed_rows.as_json)
          false
        else
          contents.as_json
        end
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
        when 'failed_rows'
          Rails.logger.tagged('NECC Dashboard cases failed to process') { Rails.logger.error message }
        end
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
        child = Child.find_by(full_name: row['child_full_name'])
        return false unless child

        params = field_mapping(row)
        return false unless TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child).update!(params)

        true
      end

      def field_mapping(row)
        {
          attendance_risk: row['attendance_risk'],
          absences: row['absences'],
          earned_revenue: row['earned_revenue'],
          estimated_revenue: row['estimated_revenue'],
          full_days: row['full_days'],
          hours: row['hours'],
          transportation_revenue: row['transportation_revenue']
        }
      end
    end
  end
end
