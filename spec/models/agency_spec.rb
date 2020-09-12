# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Agency, type: :model do
  it { should validate_presence_of(:name) }
  it { should belong_to(:state) }

  it 'factory should be valid (default; no args)' do
    expect(build(:agency)).to be_valid
  end
end

# == Schema Information
#
# Table name: agencies
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_agencies_on_name_and_state_id  (name,state_id) UNIQUE
#
