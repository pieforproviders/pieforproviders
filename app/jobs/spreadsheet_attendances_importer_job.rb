# frozen_string_literal: true

# Job to fill out center spreadsheets for a user, month and year
class SpreadsheetAttendancesImporterJob < ApplicationJob
  def perform_now(user_id:, month:, year:)
    AttendanceSpreadsheet::SpreadsheetAttendancesImporter.new(provider: user_id, month: month, year: year).call
  end
end