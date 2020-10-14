# frozen_string_literal: true

FactoryBot.define do
  factory :approval do
    case_number { Faker::Number.number(digits: 10) }
    copay { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    copay_frequency { Copays.frequencies.keys.sample }
    effective_on { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }
    expires_on { effective_on + 1.year }

    transient do
      create_children { true }
    end

    after(:create) do |approval, evaluator|
      approval.children << create_list(:child, rand(1..3)) if evaluator.create_children
    end
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer          default(0), not null
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :enum
#  effective_on    :date
#  expires_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
