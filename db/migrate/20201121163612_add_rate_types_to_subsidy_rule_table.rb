class AddRateTypesToSubsidyRuleTable < ActiveRecord::Migration[6.0]
  def change
    add_column :illinois_subsidy_rules, :part_day_rate, :decimal
    add_column :illinois_subsidy_rules, :full_day_rate, :decimal
  end
end
