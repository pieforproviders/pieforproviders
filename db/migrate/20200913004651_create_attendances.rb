class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances, id: :uuid do |t|
      t.references :child_site, type: :uuid, null: false, foreign_key: true
      t.references :child_case_cycle, type: :uuid, null: false, foreign_key: true
      t.string :slug, null: false, index: { unique: true }

      t.date :starts_on, null: false
      t.time :check_in, null: false
      t.time :check_out, null: false
      t.interval :total_time_in_care, null: false, comment: 'Calculated: check_out time - check_in time'

      t.timestamps
    end
  end
end
