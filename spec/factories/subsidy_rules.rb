# frozen_string_literal: true

FactoryBot.define do
  factory :subsidy_rule do
    sequence(:name) { |n| "Subsidy Rule #{n}" }
    max_age { 18 }
    license_type { Licenses.types.values.sample }
    effective_on { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }
    expires_on { effective_on + 1.year }
    factory :subsidy_rule_for_illinois do
      state { 'IL' }
      county { 'Cook' }
      association :subsidy_ruleable, factory: :illinois_subsidy_rule
    end
  end
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                    :uuid             not null, primary key
#  county                :string
#  effective_on          :date
#  expires_on            :date
#  license_type          :string           not null
#  max_age               :decimal(, )      not null
#  name                  :string           not null
#  state                 :string
#  subsidy_ruleable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  subsidy_ruleable_id   :bigint
#
# Indexes
#
#  subsidy_ruleable_index  (subsidy_ruleable_type,subsidy_ruleable_id)
#
