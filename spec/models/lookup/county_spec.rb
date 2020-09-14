# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lookup::County do
  it { should belong_to(:state) }
  it { should validate_presence_of(:name) }
  it 'validates uniqueness of the name, scoped to a state and is not case sensitive' do
    new_county = CreateOrSampleLookup.random_county_or_create
    expect(new_county).to validate_uniqueness_of(:name).scoped_to(:state_id)
                                                       .case_insensitive
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
