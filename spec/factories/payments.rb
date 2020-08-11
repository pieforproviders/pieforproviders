# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    paid_on { Faker::Date.between(from: care_finished_on, to: Time.zone.today) }
    care_started_on { Faker::Date.backward(days: 365) }
    care_finished_on { Faker::Date.between(from: care_started_on, to: Time.zone.today) }
    amount { Faker::Number.between(from: 0, to: 99_999_999) }
    discrepancy { Faker::Number.between(from: 0, to: amount) }
    agency
    site
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                :uuid             not null, primary key
#  amount_cents      :integer          default(0), not null
#  care_finished_on  :date             not null
#  care_started_on   :date             not null
#  discrepancy_cents :integer          default(0), not null
#  paid_on           :date             not null
#  slug              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  agency_id         :uuid             not null
#  site_id           :uuid             not null
#
# Indexes
#
#  index_payments_on_site_id                (site_id)
#  index_payments_on_site_id_and_agency_id  (site_id,agency_id)
#
