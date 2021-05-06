class CreateNebraskaRates < ActiveRecord::Migration[6.1]
  def change
    create_table :nebraska_rates, id: :uuid do |t|
      t.string :county, null: false
      t.decimal :max_age, null: false
      t.string :license_type, null: false
      t.string :rate_type, null: false
      t.decimal :qris_enhancement_threshold, null: false
      t.decimal :special_needs_enhancement_threshold, null: false
      t.decimal :accreditation_enhancement_threshold, null: false
      t.date :effective_on, null: false
      t.date :expires_on

      t.timestamps
    end

    add_reference :child_approvals, :nebraska_rate, type: :uuid, foreign_key: true

  end
end
