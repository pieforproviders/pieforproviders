# frozen_string_literal: true

task attendance_pdf_importer: :environment do
  AttendancePdfImporter.new.call
  sleep 5
end
