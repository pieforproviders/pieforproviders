# frozen_string_literal: true

require 'open-uri'

module Wonderschool
  module Necc
    # Wonderschool NECC Attendance CSV Importer
    class AttendanceCsvImporter
      include AppsignalReporting
      def initialize
        @client = AwsClient.new
        @uri = Rails.application.config.wonderschool_attendance_url
        @archive_bucket = Rails.application.config.aws_necc_attendance_archive_bucket
        @archive_file_name = "wonderschool-attendances-#{Time.current.strftime('%Y-%m-%d %H:%M:%S.%L')}"
      end

      def call
        process_attendances
      end

      private

      def process_attendances
        parsed_csv = CsvParser.new(uri_contents).call
        parsed_csv.each { |row| process_row(row) }
        @client.archive_contents(@archive_bucket, @archive_file_name, parsed_csv)
      end

      def uri_contents
        URI.parse(@uri).open
      end

      def process_row(row)
        child = Child.find_by(wonderschool_id: row['child_id'])

        log_missing_child(row['child_id']) and return unless child

        attendance = child.attendances.find_or_initialize_by(wonderschool_id: row['attendance_id'])
        check_in = row['checked_in_at']

        attendance.update!(child_approval: child.active_child_approval(check_in), check_in: check_in, check_out: row['checked_out_at'])
      rescue StandardError => e
        send_appsignal_error('attendance-csv-importer', e, row['child_id'])
      end

      def log_missing_child(id)
        Rails.logger.tagged('attendance import') do
          Rails.logger.info "Child with Wonderschool ID #{id} not in Pie; skipping"
        end
      end
    end
  end
end
