class ReAddStateRulesIndex < ActiveRecord::Migration[6.1]
  def change

      add_reference :rates, :state_rule, type: :uuid, polymorphic: true, index: { name: 'state_rule_index' }
      add_reference :child_approvals, :rate, type: :uuid, foreign_key: true

  end
end
