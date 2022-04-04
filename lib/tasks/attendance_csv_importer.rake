# frozen_string_literal: true

task attendance_csv_importer: :environment do
  # Pull single file from Wonderschool URL
  # Process single file through Attendance Processor
  # Archive file to S3
  AttendanceCsvImporter.new.call
  Appsignal.stop 'read_wonderschool_necc_attendances'
  sleep 5
end
