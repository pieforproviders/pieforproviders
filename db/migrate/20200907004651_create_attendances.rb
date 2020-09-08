class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances, id: :uuid do |t|
      t.references :child_case_cycle, type: :uuid, null: false, foreign_key: true

      t.string :slug, null: false, index: { unique: true }
      t.date :starts_on, null: false

      t.timestamps
    end
  end
end
