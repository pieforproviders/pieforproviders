# frozen_string_literal: true

module Wonderschool
  module Necc
    # Wonderschool NECC Attendance CSV Importer
    class AttendanceCsvImporter < RemoteCsvImporter
      private

      def action
        'attendance csv importer'
      end

      def uri
        Rails.application.config.wonderschool_attendance_url
      end

      def archive_bucket
        Rails.application.config.aws_necc_attendance_archive_bucket
      end

      def process_row(row)
        return false unless row['child_id']

        @row = row
        @child = child

        unless @child
          logger.tagged('attendance import') { logger.info "Child with Wonderschool ID #{@row['child_id']} not in Pie; skipping" }
          return true
        end

        attendance.update!(child_approval: @child.active_child_approval(check_in), check_in: check_in, check_out: check_out)
      rescue StandardError => e
        send_error(e, row['child_id']) # returns false
      end

      def child
        Child.find_by(wonderschool_id: @row['child_id'])
      end

      def check_in
        @row['checked_in_at']
      end

      def check_out
        @row['checked_out_at']
      end

      def attendance
        @child.attendances.find_or_initialize_by(wonderschool_id: @row['attendance_id'])
      end
    end
  end
end
