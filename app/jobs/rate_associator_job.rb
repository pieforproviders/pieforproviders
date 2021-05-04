# frozen_string_literal: true

# Job to associate subsidy rules to children
class RateAssociatorJob < ApplicationJob
  def perform(child_id)
    child = Child.find_by(id: child_id)
    return unless child

    RateAssociator.new(child).call
  end
end
