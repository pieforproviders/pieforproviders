class MakeSubsidyRulesPolymorphic < ActiveRecord::Migration[6.0]
  def change
    add_reference :subsidy_rules, :subsidy_ruleable, polymorphic: true, index: { name: :subsidy_ruleable_index }
    add_column :subsidy_rules, :effective_on, :date
    add_column :subsidy_rules, :expires_on, :date
    create_table :illinois_subsidy_rules, id: :uuid do |t|
      t.decimal :bronze_percentage
      t.decimal :silver_percentage
      t.decimal :gold_percentage

      t.timestamps
    end
    create_table :rate_types, id: :uuid do |t|
      t.string :name, null: false
      t.monetize :amount, null: false
      t.decimal :max_duration
      t.decimal :threshold

      t.timestamps
    end
    create_table :subsidy_rule_rate_types, id: :uuid do |t|
      t.references :subsidy_rule, type: :uuid, foreign_key: true
      t.references :rate_type, null: false, type: :uuid, foreign_key: true
    end
    create_table :child_approval_rate_types, id: :uuid do |t|
      t.references :child_approval, type: :uuid, foreign_key: true
      t.references :rate_type, null: false, type: :uuid, foreign_key: true
    end
  end
end
