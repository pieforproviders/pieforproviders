class CreateChildCaseCycles < ActiveRecord::Migration[6.0]
  def change
    create_table :child_case_cycles, id: :uuid do |t|
      t.string :slug, null: false, index: { unique: true }
      t.integer :part_days_allowed, null: false
      t.integer :full_days_allowed, null: false
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :child, type: :uuid, null: false, foreign_key: true
      t.references :subsidy_rule, type: :uuid, null: false, foreign_key: true
      t.references :case_cycle, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
