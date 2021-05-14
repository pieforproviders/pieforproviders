# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # processes Attendance data exported from Wonderschool for the NECC partnership
    class AttendanceProcessor
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

        failed_attendances = []
        contents.each { |row| process_attendance(row) || failed_attendances << row }

        if failed_attendances.present?
          log('failed_attendances', failed_attendances.flatten.to_s)
          store('failed_attendances', failed_attendances.flatten.to_s)
          return false
        end
        contents.to_s
      end

      def log(type, message)
        case type
        when 'blank_contents'
          Rails.logger.tagged('NECC Attendance file cannot be processed') { Rails.logger.error message }
        when 'failed_attendances'
          Rails.logger.tagged('NECC Attendances failed to process') { Rails.logger.error message }
        end
      end

      def store(file_name, data)
        @storage_client.put_object({ bucket: archive_bucket, body: data, key: file_name })
      end

      def csv_contents
        return false if @input.is_a?(Pathname) && !File.exist?(@input)

        contents = @input.is_a?(Pathname) ? File.read(@input.to_s) : @input
        CSV.parse(
          contents,
          headers: true,
          return_headers: false,
          skip_lines: /^(,*|\s*)$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        )
      end

      def process_attendance(row)
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

      def archive_bucket
        Rails.application.config.aws_necc_attendance_archive_bucket
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
