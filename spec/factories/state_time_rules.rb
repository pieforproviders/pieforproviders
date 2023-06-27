# frozen_string_literal: true

FactoryBot.define do
  factory :state_time_rule do
    id { SecureRandom.uuid }
    max_time { 3600 * 10 }
    min_time { 3600 * 5 }
    name { '' }
    created_at { Time.current.at_beginning_of_day }
    updated_at { created_at }
    state
  end
end

# == Schema Information
#
# Table name: state_time_rules
#
#  id         :uuid             not null, primary key
#  max_time   :integer
#  min_time   :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_state_time_rules_on_state_id  (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#