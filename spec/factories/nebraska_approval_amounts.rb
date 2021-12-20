# frozen_string_literal: true

FactoryBot.define do
  factory :nebraska_approval_amount do
    allocated_family_fee { Faker::Number.decimal(l_digits: 2) }
    effective_on { (Time.current - 9.months).to_date }
    expires_on { effective_on + 1.year }
    family_fee { Faker::Number.decimal(l_digits: 2) }
    child_approval
  end
end

# == Schema Information
#
# Table name: nebraska_approval_amounts
#
#  id                   :uuid             not null, primary key
#  allocated_family_fee :decimal(, )      not null
#  deleted_at           :date
#  effective_on         :date             not null
#  expires_on           :date             not null
#  family_fee           :decimal(, )      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  child_approval_id    :uuid             not null
#
# Indexes
#
#  index_nebraska_approval_amounts_on_child_approval_id  (child_approval_id)
#  index_nebraska_approval_amounts_on_effective_on       (effective_on)
#  index_nebraska_approval_amounts_on_expires_on         (expires_on)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
