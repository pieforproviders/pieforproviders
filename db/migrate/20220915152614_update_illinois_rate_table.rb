class UpdateIllinoisRateTable < ActiveRecord::Migration[6.1]
  def change
    change_table :illinois_rates do |t|
      t.rename :county, :region
      t.rename :max_age, :age_bucket
      t.string :rate_type, null: false
      t.decimal :amount, null: false
    end
    remove_column  :illinois_rates, :bronze_percentage, :decimal
    remove_column  :illinois_rates, :gold_percentage, :decimal
    remove_column  :illinois_rates, :attendance_threshold, :decimal
    remove_column :illinois_rates, :part_day_rate, :decimal
    remove_column  :illinois_rates, :full_day_rate, :decimal
    change_column_null :illinois_rates, :age_bucket, true
  end
end
