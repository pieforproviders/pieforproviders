# frozen_string_literal: true

FactoryBot.define do
  factory :approval do
    case_number { Faker::Number.number(digits: 10) }
    copay_cents { Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000) }
    copay_frequency { copay ? Copays.frequencies.keys.sample : nil }
    effective_on { Faker::Date.between(from: 11.months.ago, to: 3.months.ago) }
    expires_on { effective_on + 1.year }

    transient do
      create_children { true }
      num_children { rand(1..3) }
      business { create(:business) }
    end

    after(:create) do |approval, evaluator|
      approval.children << create_list(:child, evaluator.num_children, business: evaluator.business) if evaluator.create_children
    end

    factory :expired_approval do
      effective_on { DateTime.now.in_time_zone('Central Time (US & Canada)') - 2.years }
      expires_on { DateTime.now.in_time_zone('Central Time (US & Canada)') - 1.year }
    end
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :string
#  effective_on    :date
#  expires_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
