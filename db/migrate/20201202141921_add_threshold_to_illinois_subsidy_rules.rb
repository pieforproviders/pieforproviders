class AddThresholdToIllinoisSubsidyRules < ActiveRecord::Migration[6.0]
  def change
    add_column :illinois_subsidy_rules, :attendance_threshold, :decimal
  end
end
