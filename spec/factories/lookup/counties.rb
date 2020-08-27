# frozen_string_literal: true

FactoryBot.define do
  factory :county, class: Lookup::County do
    name { Faker::Address.community }
    state
    zipcodes { [build(:zipcode)] }
  end
end

# == Schema Information
#
# Table name: lookup_counties
#
#  id          :uuid             not null, primary key
#  abbr        :string
#  county_seat :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state_id    :uuid
#
# Indexes
#
#  index_lookup_counties_on_name               (name)
#  index_lookup_counties_on_state_id           (state_id)
#  index_lookup_counties_on_state_id_and_name  (state_id,name) UNIQUE
#
