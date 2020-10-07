# frozen_string_literal: true

FactoryBot.define do
  factory :subsidy_rule do
    sequence(:name) { |n| "Subsidy Rule #{n}" }
    max_age { 18 }
    part_day_rate { 18.00 }
    full_day_rate { 32.00 }
    part_day_max_hours { 5 }
    full_day_max_hours { 12 }
    full_plus_part_day_max_hours { 18 }
    full_plus_full_day_max_hours { 24 }
    part_day_threshold { 5 }
    full_day_threshold { 6 }
    license_type { Licenses.types.values.sample }
    qris_rating { Faker::Number.between(from: 1, to: 5).to_s }
    county
    state { county.state }
  end
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                           :uuid             not null, primary key
#  full_day_max_hours           :decimal(, )      not null
#  full_day_rate_cents          :integer          default(0), not null
#  full_day_rate_currency       :string           default("USD"), not null
#  full_day_threshold           :decimal(, )      not null
#  full_plus_full_day_max_hours :decimal(, )      not null
#  full_plus_part_day_max_hours :decimal(, )      not null
#  license_type                 :enum             not null
#  max_age                      :decimal(, )      not null
#  name                         :string           not null
#  part_day_max_hours           :decimal(, )      not null
#  part_day_rate_cents          :integer          default(0), not null
#  part_day_rate_currency       :string           default("USD"), not null
#  part_day_threshold           :decimal(, )      not null
#  qris_rating                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  county_id                    :uuid
#  state_id                     :uuid             not null
#
# Indexes
#
#  index_subsidy_rules_on_county_id  (county_id)
#  index_subsidy_rules_on_state_id   (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (state_id => states.id)
#
