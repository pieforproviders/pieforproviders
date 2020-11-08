class AddStateCountyIndexToSubsidyRule < ActiveRecord::Migration[6.0]
  def change
    add_index :subsidy_rules, [:state_id, :county_id]
  end
end
