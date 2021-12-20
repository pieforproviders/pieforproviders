class AddIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :service_days, :date
    add_index :approvals, :effective_on
    add_index :approvals, :expires_on
    add_index :children, :deleted_at
    add_index :attendances, :absence
    add_index :schedules, :weekday
    add_index :schedules, :updated_at
    add_index :schedules, :effective_on
    add_index :schedules, :expires_on
  end
end
