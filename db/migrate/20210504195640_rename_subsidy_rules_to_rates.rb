class RenameSubsidyRulesToRates < ActiveRecord::Migration[6.1]
  def change
      remove_reference :subsidy_rules, :subsidy_ruleable
      remove_column :subsidy_rules, :subsidy_ruleable_type
      remove_column :child_approvals, :subsidy_rule_id

      rename_table :subsidy_rules, :rates
      rename_table :illinois_subsidy_rules, :illinois_rates

  end
end
