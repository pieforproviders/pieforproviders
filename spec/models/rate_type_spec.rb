# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateType, type: :model do
  it { should validate_presence_of(:name) }
  it { is_expected.to monetize(:amount) }

  it 'factory should be valid (default; no args)' do
    expect(build(:rate_type)).to be_valid
  end
end

# == Schema Information
#
# Table name: rate_types
#
#  id              :uuid             not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  max_duration    :decimal(, )
#  name            :string           not null
#  threshold       :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
