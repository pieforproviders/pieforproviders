# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # processes Attendance data exported from Wonderschool for the NECC partnership
    class AttendanceProcessor
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
        contents.each { |row| process_attendance(row) || failed_rows << row }

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
          Rails.logger.tagged('NECC Attendance file is blank') { Rails.logger.error message }
        else
          Rails.logger.tagged('NECC Attendances failed to process') { Rails.logger.error message }
        end
      end

      def read_csv_file
        CSV.read(
          @input,
          headers: true,
          return_headers: false,
          skip_lines: /^(?:,\s*)+$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        )
      end

      def parse_string_to_csv
        CSV.parse(
          @input,
          headers: true,
          return_headers: false,
          skip_lines: /^(?:,\s*)+$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        )
      end

      def process_attendance(row)
        child = Child.find_by(wonderschool_id: row['child_id'])
        return false unless child

        check_in = row['checked_in_at']
        check_out = row['checked_out_at']
        return false unless child.attendances.find_or_create_by!(
          child_approval: child.active_child_approval(check_in),
          check_in: check_in,
          check_out: check_out
        )

        true
      end
    end
  end
end
