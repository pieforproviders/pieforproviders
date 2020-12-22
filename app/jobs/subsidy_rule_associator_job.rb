# frozen_string_literal: true

# Job to associate subsidy rules to children
class SubsidyRuleAssociatorJob < ApplicationJob
  def perform(child_id)
    child = Child.find_by(id: child_id)
    return unless child

    SubsidyRuleAssociator.new(child).call
  end
end
