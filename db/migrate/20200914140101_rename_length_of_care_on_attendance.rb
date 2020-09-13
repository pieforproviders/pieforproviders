class RenameLengthOfCareOnAttendance < ActiveRecord::Migration[6.0]
  def change
    rename_column :attendances, :length_of_care, :attendance_duration
  end
end
