class AddTemporaryNebraskaDashboardCases < ActiveRecord::Migration[6.1]
  def change
    create_table :temporary_nebraska_dashboard_cases, id: :uuid do |t|
      t.references :child, type: :uuid, null: false, foreign_key: true, index: true
      t.text :attendance_risk
      t.text :absences
      t.text :earned_revenue
      t.text :estimated_revenue
      t.text :full_days
      t.text :hours
      t.text :transportation_revenue

      t.timestamps
    end
  end
end
