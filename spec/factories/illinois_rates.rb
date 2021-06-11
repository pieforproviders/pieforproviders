# frozen_string_literal: true

FactoryBot.define do
  factory :illinois_rate do
    sequence(:name) { |n| "Rate #{n}" }
    max_age { 18 }
    license_type { Licenses::TYPES.sample }
    effective_on { (Time.current - 11.months).to_date }
    expires_on { Random.rand(10) > 7 ? nil : effective_on + 1.year } # TODO: make this a trait and control it rather than randomizing
    county { 'Cook' }

    trait :fifty_percent do
      attendance_threshold { 0.50 }
    end

    # set a decimal value 90% of the time; 10% set to nil
    # TODO: make these traits and control it rather than randomizing
    bronze_percentage { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Number.decimal(l_digits: 2, r_digits: 2) : nil }
    silver_percentage { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Number.decimal(l_digits: 2, r_digits: 2) : nil }
    gold_percentage { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Number.decimal(l_digits: 2, r_digits: 2) : nil }
    attendance_threshold { Faker::Number.decimal(l_digits: 0, r_digits: 3) }
  end
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                   :uuid             not null, primary key
#  attendance_threshold :decimal(, )
#  bronze_percentage    :decimal(, )
#  county               :string           default(" "), not null
#  effective_on         :date             default(Fri, 21 May 2021), not null
#  expires_on           :date
#  full_day_rate        :decimal(, )
#  gold_percentage      :decimal(, )
#  license_type         :string           default("licensed_family_home"), not null
#  max_age              :decimal(, )      default(0.0), not null
#  name                 :string           default("Rule Name Filler"), not null
#  part_day_rate        :decimal(, )
#  silver_percentage    :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
