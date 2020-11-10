# frozen_string_literal: true

FactoryBot.define do
  factory :child_approval_rate_type do
    child_approval
    rate_type
  end
end

# == Schema Information
#
# Table name: child_approval_rate_types
#
#  id                :uuid             not null, primary key
#  approved_amount   :decimal(, )
#  child_approval_id :uuid
#  rate_type_id      :uuid             not null
#
# Indexes
#
#  index_child_approval_rate_types_on_child_approval_id  (child_approval_id)
#  index_child_approval_rate_types_on_rate_type_id       (rate_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#  fk_rails_...  (rate_type_id => rate_types.id)
#
