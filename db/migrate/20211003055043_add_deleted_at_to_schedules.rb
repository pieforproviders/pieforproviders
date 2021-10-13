class AddDeletedAtToSchedules < ActiveRecord::Migration[6.1]
  def change
    add_column :schedules, :deleted_at, :date
  end
end
