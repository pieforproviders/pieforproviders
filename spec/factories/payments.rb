# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    child_approval
    month { 7.months.ago.to_date }
    amount { Faker::Number.within(range: 10.0..200.0) }
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                :uuid             not null, primary key
#  amount            :decimal(, )      not null
#  month             :date             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  child_approval_id :uuid             not null
#
# Indexes
#
#  index_payments_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
