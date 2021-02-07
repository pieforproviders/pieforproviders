# frozen_string_literal: true

require 'csv'

# reads in Attendance CSVs exported from Wonderschool for NECC partnership
class WonderschoolNeccAttendanceReader
  def initialize(file)
    @file = file
  end

  def call
    read
  end

  private

  def read
    return nil unless File.file?(@file)

    csv_rows = read_csv
    failed_rows = []
    csv_rows.each { |row| process_attendance(row) || failed_rows << row }

    Rails.logger.tagged('NECC Attendances failed to parse') { Rails.logger.error failed_rows.to_s } if failed_rows.present?
  end

  def read_csv
    CSV.read(@file,
             headers: true,
             return_headers: false,
             unconverted_fields: %i[child_id],
             converters: %i[date])
  end

  def process_attendance(row)
    child = Child.find_by(wonderschool_id: row['child_id'])
    return false unless child

    check_in = row['checked_in_at'].in_time_zone(child.timezone)
    check_out = row['checked_out_at'].in_time_zone(child.timezone)
    return false unless child.attendances.find_or_create_by!(
      child_approval: child.active_child_approval(check_in),
      check_in: check_in,
      check_out: check_out
    )

    true
  end
end
