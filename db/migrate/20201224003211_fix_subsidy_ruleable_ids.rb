class FixSubsidyRuleableIds < ActiveRecord::Migration[6.0]
  def change
    remove_reference :subsidy_rules, :subsidy_ruleable, polymorphic: true, index: true
    add_reference :subsidy_rules, :subsidy_ruleable, type: :uuid, polymorphic: true, index: { name: 'subsidy_ruleable_index' }
  end
end
