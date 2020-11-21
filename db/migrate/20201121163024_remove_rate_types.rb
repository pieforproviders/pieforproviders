class RemoveRateTypes < ActiveRecord::Migration[6.0]
  def up
    drop_table :subsidy_rule_rate_types
    drop_table :billable_occurrence_rate_types
    drop_table :child_approval_rate_types
    drop_table :rate_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
