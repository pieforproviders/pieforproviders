# frozen_string_literal: true

FactoryBot.define do
  factory :zipcode, class: Lookup::Zipcode do
    code { Faker::Address.zip_code(state_abbreviation: state.abbr) }
    state
  end
end

# == Schema Information
#
# Table name: lookup_zipcodes
#
#  id         :uuid             not null, primary key
#  area_code  :string
#  code       :string           not null
#  lat        :decimal(15, 10)
#  lon        :decimal(15, 10)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city_id    :uuid
#  county_id  :uuid
#  state_id   :uuid
#
# Indexes
#
#  index_lookup_zipcodes_on_city_id               (city_id)
#  index_lookup_zipcodes_on_code                  (code) UNIQUE
#  index_lookup_zipcodes_on_county_id             (county_id)
#  index_lookup_zipcodes_on_state_id              (state_id)
#  index_lookup_zipcodes_on_state_id_and_city_id  (state_id,city_id)
#
