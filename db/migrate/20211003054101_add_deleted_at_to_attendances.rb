class AddDeletedAtToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :deleted_at, :date
  end
end
