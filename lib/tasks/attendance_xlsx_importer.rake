# frozen_string_literal: true

task attendance_xlsx_importer: :environment do
  AttendanceXlsxImporter.new.call
  sleep 5
end
