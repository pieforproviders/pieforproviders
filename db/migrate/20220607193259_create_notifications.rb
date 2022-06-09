class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :child, foreign_key: true, type: :uuid
      t.references :approval, foreign_key: true, type: :uuid
      t.timestamps
    end

    add_index :notifications, %i[child_id approval_id], unique: true
  end
end
