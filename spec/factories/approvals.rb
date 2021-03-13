# frozen_string_literal: true

FactoryBot.define do
  factory :approval do
    case_number { Faker::Number.number(digits: 10) }
    copay_cents { Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000) }
    copay_frequency { copay ? Copays.frequencies.keys.sample : nil }
    effective_on { (Time.current - 9.months).to_date }
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
      effective_on { (Time.current - 3.years).to_date }
      expires_on { (Time.current - 2.years).to_date }
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
