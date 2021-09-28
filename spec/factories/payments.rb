# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    child_approval
    month { (Time.current - 7.months).to_date }
    amount { Faker::Number.within(range: 10.0..200.0) }
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                        :uuid             not null, primary key
#  month                     :date             not null
#  amount                    :decimal(, )      not null
#  child_approval_id         :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)