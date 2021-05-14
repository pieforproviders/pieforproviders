class AddWonderschoolIdToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :wonderschool_id, :string
    change_column_null :attendances, :check_out, true
  end
end
