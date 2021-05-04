# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rate, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }

  it 'factory should be valid (default; no args)' do
    expect(build(:rate_for_illinois)).to be_valid
  end
end

# == Schema Information
#
# Table name: rates
#
#  id              :uuid             not null, primary key
#  county          :string
#  effective_on    :date
#  expires_on      :date
#  license_type    :string           not null
#  max_age         :decimal(, )      not null
#  name            :string           not null
#  state           :string
#  state_rule_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  state_rule_id   :uuid
#
# Indexes
#
#  state_rule_index  (state_rule_type,state_rule_id)
#
