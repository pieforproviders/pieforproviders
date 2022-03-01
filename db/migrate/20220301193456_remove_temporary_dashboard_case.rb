class RemoveTemporaryDashboardCase < ActiveRecord::Migration[6.1]
  def change
    drop_table :temporary_nebraska_dashboard_cases
  end
end
