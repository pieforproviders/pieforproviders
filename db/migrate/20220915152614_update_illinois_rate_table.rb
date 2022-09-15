class UpdateIllinoisRateTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :illinois_rates, :bronze_percentage, :decimal
    remove_column :illinois_rates, :silver_percentage, :decimal
    remove_column :illinois_rates, :gold_percentage, :decimal
    remove_column :illinois_rates, :attendance_threshold, :decimal
    rename_column :illinois_rates, :county, :region
    rename_column :illinois_rates, :max_age, :age_bucket
    remove_column :illinois_rates, :part_day_rate, :decimal
    remove_column :illinois_rates, :full_day_rate, :decimal
    add_column :illinois_rates, :rate_type, :string, null: false
  end
end
