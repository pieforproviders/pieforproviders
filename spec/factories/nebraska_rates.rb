# frozen_string_literal: true

FactoryBot.define do
  factory :nebraska_rate do
    sequence(:name) { |n| "Rate #{n}" }
    max_age { 18 }
    amount { Faker::Number.decimal(l_digits: 2) }
    license_type { Licenses::TYPES.sample }
    effective_on { (Time.current - 11.months).to_date }
    expires_on { Random.rand(10) > 7 ? nil : effective_on + 1.year } # TODO: make this a trait and control it rather than randomizing
    county { 'Douglas' }
    rate_type { NebraskaRate::TYPES.sample }
    region { NebraskaRate::REGIONS.sample }

    trait :accredited do
      accredited_rate { true }
    end
  end
end

# == Schema Information
#
# Table name: nebraska_rates
#
#  id              :uuid             not null, primary key
#  accredited_rate :boolean          default(FALSE), not null
#  amount          :decimal(, )      not null
#  county          :string           not null
#  effective_on    :date             not null
#  expires_on      :date
#  license_type    :string           not null
#  max_age         :decimal(, )      not null
#  name            :string           not null
#  rate_type       :string           not null
#  region          :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
