class RemoveCaseCycles < ActiveRecord::Migration[6.0]
  def change
    # if we roll this back we'll need to add a value with a data migration and then change this to null:false
    remove_reference :attendances, :child_case_cycle, type: :uuid, index: true, foreign_key: true
    drop_table :child_case_cycles, id: :uuid do |t|
      t.integer :part_days_allowed, null: false
      t.integer :full_days_allowed, null: false
      t.references :child, type: :uuid, null: false, foreign_key: true
      t.references :subsidy_rule, type: :uuid, null: false, foreign_key: true
      t.references :case_cycle, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    drop_table :case_cycles, id: :uuid do |t|
      t.string :case_number
      t.monetize :copay
      t.date :submitted_on, null: false
      t.date :effective_on
      t.date :notified_on
      t.date :expires_on
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.column :status, :case_status, null: false, default: 'submitted'
      t.column :copay_frequency, :copay_frequency, null: false

      t.timestamps
    end
  end
end
