class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules, id: :uuid do |t|
      t.date :effective_on, null: false
      t.datetime :end_time, null: false
      t.date :expires_on
      t.datetime :start_time, null: false
      t.integer :weekday, null: false

      t.references :child, type: :uuid, null: false, index: true, foreign_key: true
      
      t.index %i[effective_on child_id], unique: true, name: :unique_child_schedules
      
      t.timestamps
    end
  end
end
