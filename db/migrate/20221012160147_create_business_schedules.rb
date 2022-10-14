class CreateBusinessSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :business_schedules, id: :uuid do |t|
      t.integer :weekday, null: false
      t.boolean :is_open, null: false

      t.references :business, type: :uuid, null: false, index: true, foreign_key: true
      
      t.index %i[business_id weekday], unique: true, name: :unique_business_schedules
      t.timestamps
    end
  end
end
