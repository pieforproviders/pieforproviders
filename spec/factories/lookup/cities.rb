# frozen_string_literal: true

FactoryBot.define do
  factory :city, class: Lookup::City do
    name { Faker::Address.city }
    state
  end
end

# == Schema Information
#
# Table name: lookup_cities
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  county_id  :uuid
#  state_id   :uuid             not null
#
# Indexes
#
#  index_lookup_cities_on_county_id          (county_id)
#  index_lookup_cities_on_name               (name)
#  index_lookup_cities_on_name_and_state_id  (name,state_id) UNIQUE
#  index_lookup_cities_on_state_id           (state_id)
#
