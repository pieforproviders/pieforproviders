class RenameAttendancesTotalTimeInCare < ActiveRecord::Migration[6.1]
  def change
    rename_column :attendances, :total_time_in_care, :time_in_care
  end
end
