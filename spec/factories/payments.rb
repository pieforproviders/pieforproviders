# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    paid_on { Faker::Date.between(from: care_finished_on, to: Time.zone.today) }
    care_started_on { Faker::Date.backward(days: 365) }
    care_finished_on { Faker::Date.between(from: care_started_on, to: Time.zone.today) }
    amount { Faker::Number.between(from: 1, to: 999_999) }
    # Set a discrepancy value about 20% of the time:
    discrepancy { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Number.between(from: 0, to: amount) : nil }
    agency
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount_cents         :integer          default(0), not null
#  amount_currency      :string           default("USD"), not null
#  care_finished_on     :date             not null
#  care_started_on      :date             not null
#  discrepancy_cents    :integer
#  discrepancy_currency :string           default("USD")
#  paid_on              :date             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  agency_id            :uuid             not null
#
