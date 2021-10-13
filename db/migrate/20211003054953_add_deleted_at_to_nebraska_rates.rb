class AddDeletedAtToNebraskaRates < ActiveRecord::Migration[6.1]
  def change
    add_column :nebraska_rates, :deleted_at, :date
  end
end
