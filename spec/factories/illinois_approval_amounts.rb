# frozen_string_literal: true

FactoryBot.define do
  factory :illinois_approval_amount do
    month { 7.months.ago.to_date }
    part_days_approved_per_week { Faker::Number.within(range: 0..5) }
    full_days_approved_per_week { Faker::Number.within(range: 0..5) }
    child_approval
  end
end

# == Schema Information
#
# Table name: illinois_approval_amounts
#
#  id                          :uuid             not null, primary key
#  deleted_at                  :date
#  full_days_approved_per_week :integer
#  month                       :date             not null
#  part_days_approved_per_week :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  child_approval_id           :uuid             not null
#
# Indexes
#
#  index_illinois_approval_amounts_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
