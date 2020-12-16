# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lookup::State do
  it { should validate_presence_of(:abbr) }
  it 'validates uniqueness of the state abbr' do
    new_state = CreateOrSampleLookup.random_state_or_create
    expect(new_state).to validate_uniqueness_of(:abbr).case_insensitive
  end
  it { should validate_presence_of(:name) }
  it 'validates uniqueness of the name' do
    new_state = CreateOrSampleLookup.random_state_or_create
    expect(new_state).to validate_uniqueness_of(:name).case_insensitive
  end
end

# == Schema Information
#
# Table name: lookup_states
#
#  id         :uuid             not null, primary key
#  abbr       :string(2)        not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_lookup_states_on_abbr  (abbr) UNIQUE
#  index_lookup_states_on_name  (name) UNIQUE
#
