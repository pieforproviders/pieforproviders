class DropTransportationAndAddFamilyFee < ActiveRecord::Migration[6.1]
  def change
    remove_column :temporary_nebraska_dashboard_cases, :transportation_revenue, :text
    add_column :temporary_nebraska_dashboard_cases, :family_fee, :decimal
  end
end
