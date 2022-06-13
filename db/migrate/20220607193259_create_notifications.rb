class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :child, foreign_key: true, type: :uuid, unique: true
      t.references :approval, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
