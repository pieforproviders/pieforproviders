class RemoveRateTable < ActiveRecord::Migration[6.1]
  def change
    add_column :illinois_rates, :county, :string, null: false, default: ' '
    add_column :illinois_rates, :effective_on, :date, null: false, default: Time.zone.now.to_date
    add_column :illinois_rates, :expires_on, :date
    add_column :illinois_rates, :license_type, :string, null: false, default: 'licensed_family_home'
    add_column :illinois_rates, :max_age, :decimal, null: false, default: 0
    add_column :illinois_rates, :name, :string, null: false, default: 'Rule Name Filler'
    remove_reference :child_approvals, :rate, type: :uuid, foreign_key: true
    add_reference :child_approvals, :illinois_rate, type: :uuid, foreign_key: true

    drop_table :rates
  end
end
