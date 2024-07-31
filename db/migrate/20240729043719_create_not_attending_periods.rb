class CreateNotAttendingPeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :not_attending_periods, id: :uuid do |t|
      t.date :start_date
      t.date :end_date
      t.references :child, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
