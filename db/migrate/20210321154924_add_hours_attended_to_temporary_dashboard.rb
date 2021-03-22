class AddHoursAttendedToTemporaryDashboard < ActiveRecord::Migration[6.1]
  def change
    add_column :temporary_nebraska_dashboard_cases, :hours_attended, :string
  end
end
