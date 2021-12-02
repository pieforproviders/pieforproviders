# frozen_string_literal: true

FactoryBot.define do
  factory :nebraska_rate do
    sequence(:name) { |n| "Rate #{n}" }
    max_age { 120 }
    amount { Faker::Number.within(range: 10.0..50.0) }
    license_type { 'family_child_care_home_i' }
    effective_on { (Time.current - 11.months).to_date }
    # TODO: make this a trait and control it rather than randomizing
    expires_on do
      Random.rand(10) > 7 ? nil : effective_on + 1.year
    end
    county { 'Douglas' }
    rate_type { NebraskaRate::TYPES.sample }
    region { NebraskaRate::REGIONS.sample }
    school_age { false }
    accredited_rate { false }

    trait :accredited do
      accredited_rate { true }
    end

    trait :ldds do
      region { 'LDDS' }
    end

    trait :other_region do
      region { 'Other' }
    end

    trait :hourly do
      rate_type { 'hourly' }
    end
    trait :daily do
      rate_type { 'daily' }
    end

    trait :school_age do
      school_age { true }
      max_age { nil }
    end

    trait :license_exempt_home_ds do
      license_type { 'license_exempt_home' }
      region { 'Douglas-Sarpy' }
    end

    trait :license_exempt_home_ld do
      license_type { 'license_exempt_home' }
      region { 'Lancaster-Dakota' }
    end

    trait :license_exempt_home_other do
      license_type { 'license_exempt_home' }
      region { 'Other' }
    end

    trait :family_in_home do
      license_type { 'family_in_home' }
      region { 'All' }
    end

    factory :accredited_hourly_ldds_rate, traits: %i[accredited ldds hourly]
    factory :unaccredited_hourly_ldds_rate, traits: %i[ldds hourly]
    factory :unaccredited_hourly_ldds_school_age_rate, traits: %i[ldds hourly school_age]
    factory :accredited_daily_ldds_rate, traits: %i[accredited ldds daily]
    factory :unaccredited_daily_ldds_rate, traits: %i[ldds daily]
    factory :unaccredited_daily_ldds_school_age_rate, traits: %i[ldds daily school_age]
    factory :accredited_hourly_other_region_rate, traits: %i[accredited other_region hourly]
    factory :unaccredited_hourly_other_region_rate, traits: %i[other_region hourly]
    factory :unaccredited_hourly_other_region_school_age_rate, traits: %i[other_region hourly school_age]
    factory :accredited_daily_other_region_rate, traits: %i[accredited other_region daily]
    factory :unaccredited_daily_other_region_rate, traits: %i[other_region daily]
    factory :unaccredited_daily_other_region_school_age_rate, traits: %i[other_region daily school_age]
  end
end

# == Schema Information
#
# Table name: nebraska_rates
#
#  id              :uuid             not null, primary key
#  accredited_rate :boolean          default(FALSE), not null
#  amount          :decimal(, )      not null
#  county          :string
#  deleted_at      :date
#  effective_on    :date             not null
#  expires_on      :date
#  license_type    :string           not null
#  max_age         :decimal(, )
#  name            :string           not null
#  rate_type       :string           not null
#  region          :string           not null
#  school_age      :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_nebraska_rates_on_effective_on  (effective_on)
#  index_nebraska_rates_on_expires_on    (expires_on)
#
