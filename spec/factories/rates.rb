# frozen_string_literal: true

FactoryBot.define do
  factory :rate do
    sequence(:name) { |n| "Subsidy Rule #{n}" }
    max_age { 18 }
    license_type { Licenses::TYPES.sample }
    effective_on { (Time.current - 11.months).to_date }
    expires_on { Random.rand(10) > 7 ? nil : effective_on + 1.year }

    factory :rate_for_illinois do
      state { 'IL' }
      county { 'Cook' }
      association :rateable, factory: :illinois_rate

      trait :fifty_percent do
        association :rateable, factory: :illinois_rate, attendance_threshold: 0.50
      end
    end
  end
end

# == Schema Information
#
# Table name: rates
#
#  id            :uuid             not null, primary key
#  county        :string
#  effective_on  :date
#  expires_on    :date
#  license_type  :string           not null
#  max_age       :decimal(, )      not null
#  name          :string           not null
#  rateable_type :string
#  state         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  rateable_id   :uuid
#
# Indexes
#
#  rateable_index  (rateable_type,rateable_id)
#
