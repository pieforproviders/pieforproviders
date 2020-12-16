# frozen_string_literal: true

FactoryBot.define do
  factory :county do
    abbr { Faker::Address.state_abbr }
    name { Faker::Address.community }
    county_seat { Faker::Address.city }
    state
    initialize_with { County.find_or_create_by(name: name, state: state) }
  end
end

# == Schema Information
#
# Table name: counties
#
#  id          :uuid             not null, primary key
#  abbr        :string
#  county_seat :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state_id    :uuid             not null
#
# Indexes
#
#  index_counties_on_abbr_and_state_id  (abbr,state_id) UNIQUE
#  index_counties_on_name               (name)
#  index_counties_on_name_and_state_id  (name,state_id) UNIQUE
#  index_counties_on_state_id           (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#
