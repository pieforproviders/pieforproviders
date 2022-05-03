class CreateNebraskaDashboardCases < ActiveRecord::Migration[6.1]
  def change
    create_table :nebraska_dashboard_cases, id: :uuid do |t|
      t.datetime :month, null: false, default: Time.current
      t.string :attendance_risk, null: false, default: 'not_enough_info'
      t.integer :absences, null: false, default: 0
      t.monetize :earned_revenue, amount: { null: true, default: nil }
      t.monetize :estimated_revenue, amount: { null: true, default: nil }
      t.monetize :scheduled_revenue, amount: { null: true, default: nil }
      t.integer :full_days, null: false, default: 0
      t.float :hours, null: false, default: 0.0
      t.integer :full_days_remaining, null: false, default: 0
      t.float :hours_remaining, null: false, default: 0.0
      t.float :attended_weekly_hours, null: false, default: 0.0

      t.references :child, type: :uuid, null: false, index: true, foreign_key: true

      t.timestamps
    end

    add_index :nebraska_dashboard_cases, %i[month child_id], unique: true
  end
end
