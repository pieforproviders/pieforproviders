# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lookup::Zipcode do
  it { should belong_to(:state) }
  it { should validate_presence_of(:code) }
  it 'validates uniqueness of the code' do
    create(:zipcode)
    should validate_uniqueness_of(:code).case_insensitive
  end
end

# == Schema Information
#
# Table name: lookup_cities
#
#  id        :uuid             not null, primary key
#  name      :string           not null
#  county_id :uuid
#  state_id  :uuid             not null
#
# Indexes
#
#  index_lookup_cities_on_county_id          (county_id)
#  index_lookup_cities_on_name               (name)
#  index_lookup_cities_on_name_and_state_id  (name,state_id) UNIQUE
#  index_lookup_cities_on_state_id           (state_id)
#
