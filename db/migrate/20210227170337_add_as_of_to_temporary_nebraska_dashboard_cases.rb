class AddAsOfToTemporaryNebraskaDashboardCases < ActiveRecord::Migration[6.1]
  def change
    add_column :temporary_nebraska_dashboard_cases, :as_of, :string
  end
end
