# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # downloads Attendance data exported from Wonderschool for the NECC partnership
    class AttendanceDownloader < S3DownloaderBase

      def initialize()
        super()
        @logger_tag = 'NECC Attendances'
      end

      private

      def process_file(file_name)
        fetched = @client.get_object({ bucket: source_bucket, key: file_name }).body
        if read_contents(fetched)
          log(:info, "processed #{file_name}")
          move_to_archive(@client, file_name)
        else
          log(:error "failed to process #{file_name}")
        end
      end

      def read_contents(fetched_obj)
        contents ||= csv_contents(fetched_obj) #TODO: why is this ||=, when is contents already defined?
        log(:error , "could not read: #{fetched_obj.to_s}", ) and return false if contents.blank?

        failed_attendances = []
        contents.each { |row| process_attendance(row) || failed_attendances << row }

        if failed_attendances.present?
          log(:error, "failed_attendances: #{failed_attendances.flatten.to_s}", )
          store_in_archive('failed_attendances', failed_attendances.flatten.to_s)
          #TODO : what? saving this to the same filename every time? Does S3 overwrite the file?
          return false
        end
        contents.to_s
      end

      def csv_contents(input)
        return false if input.is_a?(Pathname) && !File.exist?(input)

        contents = input.is_a?(Pathname) ? File.read(input.to_s) : input
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

      def source_bucket
        Rails.application.config.aws_necc_attendance_bucket
      end

      def archive_bucket
        Rails.application.config.aws_necc_attendance_archive_bucket
      end
    end
  end
end
