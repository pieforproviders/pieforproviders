class CreateSubsidyRules < ActiveRecord::Migration[6.0]
  def change
    create_table :subsidy_rules, id: :uuid do |t|
      t.string :name, null: false
      t.column :license_type, :license_types, null: false
      t.uuid :county_id, type: :uuid, null: false, foreign_key: { to_table: :lookup_counties }, index: true
      t.uuid :state_id, type: :uuid, null: false, foreign_key: { to_table: :lookup_states }, index: true
      t.decimal :max_age, null: false
      t.monetize :part_day_rate, null: false
      t.monetize :full_day_rate, null: false
      t.decimal :part_day_max_hours, null: false
      t.decimal :full_day_max_hours, null: false
      t.decimal :full_plus_part_day_max_hours, null: false
      t.decimal :full_plus_full_day_max_hours, null: false
      t.decimal :part_day_threshold, null: false
      t.decimal :full_day_threshold, null: false
      t.string :qris_rating

      t.timestamps
    end
  end
end
