# frozen_string_literal: true

FactoryBot.define do
  factory :site do
    name { Faker::Name.child_care_sites }
    address { Faker::Address.street_address }
    state { CreateOrSampleLookup.state }
    county { CreateOrSampleLookup.county(state: state) }
    city { CreateOrSampleLookup.city(state: county.state, county: county) }
    zip { CreateOrSampleLookup.zipcode(state: city.state, city: city) }

    qris_rating { (1..5).to_a.push(nil).sample }
    business
  end
end

# == Schema Information
#
# Table name: sites
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  address     :string           not null
#  name        :string           not null
#  qris_rating :string
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#  city_id     :uuid             not null
#  county_id   :uuid             not null
#  state_id    :uuid             not null
#  zip_id      :uuid             not null
#
# Indexes
#
#  index_sites_on_name_and_business_id  (name,business_id) UNIQUE
#
