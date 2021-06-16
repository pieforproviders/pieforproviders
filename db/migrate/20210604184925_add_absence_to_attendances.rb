class AddAbsenceToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :absence, :string
  end
end
