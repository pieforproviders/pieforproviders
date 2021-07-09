# frozen_string_literal: true

module Wonderschool
  module Necc
    # Wonderschool NECC Attendance CSV Importer
    class AttendanceCsvImporter < S3CsvImporter
      private

      def action
        'attendance csv importer'
      end

      def source_bucket
        Rails.application.config.aws_necc_attendance_bucket
      end

      def archive_bucket
        Rails.application.config.aws_necc_attendance_archive_bucket
      end

      def process_row(row)
        child = Child.find_by!(wonderschool_id: row['child_id'], business: Business.find_by(name: row['school_name']))

        check_in = row['checked_in_at']
        check_out = row['checked_out_at']

        attendance = child.attendances.find_or_initialize_by(wonderschool_id: row['attendance_id'])
        attendance.update!(child_approval: child.active_child_approval(check_in), check_in: check_in, check_out: check_out)
      rescue StandardError => e
        send_error(e, row['child_id']) # returns false
      end
    end
  end
end
