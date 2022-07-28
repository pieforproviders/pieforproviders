class UpdateRateRecord2022 < ActiveRecord::Migration[6.1]
  def change
    add_column :nebraska_rates, :quality_rating, :string, default: nil
    change_column_null :nebraska_rates, :accredited_rate, :boolean, true
  end
end
