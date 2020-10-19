# frozen_string_literal: true

FactoryBot.define do
  factory :subsidy_rule do
    sequence(:name) { |n| "Subsidy Rule #{n}" }
    max_age { 18 }
    license_type { Licenses.types.values.sample }
    county
    state { county.state }
  end
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id           :uuid             not null, primary key
#  license_type :enum             not null
#  max_age      :decimal(, )      not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  county_id    :uuid
#  state_id     :uuid             not null
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
