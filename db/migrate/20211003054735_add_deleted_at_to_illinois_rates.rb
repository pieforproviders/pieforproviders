class AddDeletedAtToIllinoisRates < ActiveRecord::Migration[6.1]
  def change
    add_column :illinois_rates, :deleted_at, :date
  end
end
