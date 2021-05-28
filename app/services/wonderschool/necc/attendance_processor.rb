# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # processes Attendance data exported from Wonderschool for the NECC partnership
    class AttendanceProcessor < S3CsvProcessor

      private

      def csv_parsing_config
        {
          headers: true,
          liberal_parsing: true,
          return_headers: false,
          skip_lines: /^(,*|\s*)$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        }
      end

      def process(records)
        records.each do |row|
          child = Child.find_by(wonderschool_id: row['child_id'], business: Business.find_by(name: row['school_name']))
          return false unless child

          check_in = row['checked_in_at']
          check_out = row['checked_out_at']

          attendance = child.attendances.find_or_initialize_by(wonderschool_id: row['attendance_id'])
          attendance.update!(child_approval: child.active_child_approval(check_in), check_in: check_in, check_out: check_out)

          true
        rescue ActiveRecord::RecordInvalid => e
          log('error processing', e)
          false
        end
      end

      def source_bucket
        Rails.application.config.aws_necc_attendance_bucket
      end
      
      def archive_bucket
        Rails.application.config.aws_necc_attendance_archive_bucket
      end
    end
  end
end
