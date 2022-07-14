# frozen_string_literal: true

task attendance_csv_importer: :environment do
  # Pull single file from Wonderschool URL
  # Process single file through Attendance Processor
  # Archive file to S3
  start_date = ENV['start_date']&.to_date || 1.year.before
  end_date = ENV['end_date']&.to_date || 0.days.after
  AttendanceCsvImporter.new.call(start_date, end_date)
  Appsignal.stop 'read_wonderschool_necc_attendances'
  sleep 5
end
