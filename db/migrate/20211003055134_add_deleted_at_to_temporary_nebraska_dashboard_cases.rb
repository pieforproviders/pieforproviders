class AddDeletedAtToTemporaryNebraskaDashboardCases < ActiveRecord::Migration[6.1]
  def change
    add_column :temporary_nebraska_dashboard_cases, :deleted_at, :date
  end
end
