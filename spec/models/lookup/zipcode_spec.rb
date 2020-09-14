# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lookup::Zipcode do
  it { should belong_to(:state) }
  it { should validate_presence_of(:code) }
  it 'validates uniqueness of the code' do
    new_zipcode = CreateOrSampleLookup.random_zipcode_or_create
    expect(new_zipcode).to validate_uniqueness_of(:code).case_insensitive
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
