# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lookup::County do
  it { should belong_to(:state) }
  it { should validate_presence_of(:name) }
  it 'validates uniqueness of the name, scoped to a state and is not case sensitive' do
    create(:county)
    should validate_uniqueness_of(:name).scoped_to(:state_id)
                                        .case_insensitive
  end
end
