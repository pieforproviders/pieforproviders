# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lookup::City do
  it { should belong_to(:state) }
  it { should validate_presence_of(:name) }
  it 'validates uniqueness of the name, scoped to a state and is not case sensitive' do
    create(:city)
    should validate_uniqueness_of(:name).scoped_to(:state_id)
                                        .case_insensitive
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
