class RemoveAbsenceFromAttendances < ActiveRecord::Migration[6.1]
  def change
    remove_column :attendances, :absence, :string
  end
end
