class ChangeUniqueIndexForSchedules < ActiveRecord::Migration[6.1]
  def up
    remove_index :schedules, name: "unique_child_schedules"
    add_index :schedules, %i[effective_on child_id weekday], unique: true, name: :unique_child_schedules
  end
  def down
    remove_index :schedules, name: "unique_child_schedules"
    add_index :schedules, %i[effective_on child_id], unique: true, name: :unique_child_schedules
  end
end
