class AddNebraskaRates < ActiveRecord::Migration[6.1]
  def change
    create_table :nebraska_rates, id: :uuid do |t|
      t.string "region", null: false # ldds or other
      t.string "rate_type", null: false # daily or hourly
      t.decimal "amount", null: false
      t.string "county", null: false
      t.boolean "accredited_rate", default: false, null: false
      t.date "effective_on", null: false
      t.date "expires_on"
      t.string "license_type", null: false
      t.decimal "max_age", null: false
      t.string "name", null: false

      t.timestamps
    end
  end
end
