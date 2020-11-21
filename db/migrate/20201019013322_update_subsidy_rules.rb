class UpdateSubsidyRules < ActiveRecord::Migration[6.0]
  def change
    remove_monetize :subsidy_rules, :part_day_rate
    remove_monetize :subsidy_rules, :full_day_rate
    remove_column :subsidy_rules, :part_day_max_hours
    remove_column :subsidy_rules, :full_day_max_hours
    remove_column :subsidy_rules, :full_plus_part_day_max_hours
    remove_column :subsidy_rules, :full_plus_full_day_max_hours
    remove_column :subsidy_rules, :part_day_threshold
    remove_column :subsidy_rules, :full_day_threshold
    remove_column :subsidy_rules, :qris_rating
  end
end
