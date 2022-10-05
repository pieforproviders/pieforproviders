# frozen_string_literal: true

FactoryBot.define do
  factory :illinois_rate do
    sequence(:name) { |n| "Rate #{n}" }
    age_bucket { 18 }
    license_type { Licenses::TYPES.sample }
    effective_on { 11.months.ago.to_date }
    # TODO: make this a trait and control it rather than randomizing
    expires_on do
      Random.rand(10) > 7 ? nil : effective_on + 1.year
    end
    region { 'group_1a' }
    rate_type { 'full_day' }
    amount { 30.0 }
  end
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                :uuid             not null, primary key
#  age_bucket        :decimal(, )      default(0.0)
#  amount            :decimal(, )      not null
#  deleted_at        :date
#  effective_on      :date             not null
#  expires_on        :date
#  license_type      :string           default("licensed_family_home"), not null
#  name              :string           default("Rule Name Filler"), not null
#  rate_type         :string           not null
#  region            :string           default(" "), not null
#  silver_percentage :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_illinois_rates_on_effective_on  (effective_on)
#  index_illinois_rates_on_expires_on    (expires_on)
#
