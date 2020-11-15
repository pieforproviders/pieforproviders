# frozen_string_literal: true

FactoryBot.define do
  factory :child_approval do
    child
    approval
  end
end

# == Schema Information
#
# Table name: child_approvals
#
#  id              :uuid             not null, primary key
#  approval_id     :uuid             not null
#  child_id        :uuid             not null
#  subsidy_rule_id :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id      (approval_id)
#  index_child_approvals_on_child_id         (child_id)
#  index_child_approvals_on_subsidy_rule_id  (subsidy_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#
