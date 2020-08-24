# frozen_string_literal: true

FactoryBot.define do
  factory :case_cycle do
    case_number { Faker::Alphanumeric.alpha(number: 10) }
    status { 'submitted' }
    submitted_on { Time.zone.today }
    copay { Faker::Number.between(from: 0, to: 2000) }
    copay_frequency { 'monthly' }

    trait :pending do
      status { 'pending' }
      submitted_on { Time.zone.today - 3.months }
    end

    trait :approved do
      status { 'approved' }
      notified_on { submitted_on + 30.days }
      effective_on { submitted_on + 45.days }
      expires_on { effective_on + 1.year }
    end

    trait :denied do
      status { 'denied' }
      notified_on { submitted_on + 30.days }
    end
  end
end

# == Schema Information
#
# Table name: case_cycles
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer          default(0), not null
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :enum             not null
#  effective_on    :date
#  expires_on      :date
#  notified_on     :date
#  slug            :string           not null
#  status          :enum             default("submitted"), not null
#  submitted_on    :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_case_cycles_on_slug  (slug) UNIQUE
#
