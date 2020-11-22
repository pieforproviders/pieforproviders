# frozen_string_literal: true

FactoryBot.define do
  factory :zipcode do
    area_code { Faker::Address.building_number }
    city { Faker::Address.city }
    code { Faker::Address.zip_code }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
    county
    state { county.state }
  end
end

# == Schema Information
#
# Table name: zipcodes
#
#  id         :uuid             not null, primary key
#  area_code  :string
#  city       :string
#  code       :string           not null
#  lat        :decimal(15, 10)
#  lon        :decimal(15, 10)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  county_id  :uuid             not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_zipcodes_on_code         (code) UNIQUE
#  index_zipcodes_on_county_id    (county_id)
#  index_zipcodes_on_lat_and_lon  (lat,lon)
#  index_zipcodes_on_state_id     (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (state_id => states.id)
#
