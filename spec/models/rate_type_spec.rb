# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateType, type: :model do
  it { should validate_presence_of(:name) }
  it { is_expected.to monetize(:amount) }
  it { should have_many(:child_approval_rate_types).dependent(:restrict_with_error) }
  it { should have_many(:child_approvals).through(:child_approval_rate_types) }
  it { should have_many(:billable_occurrence_rate_types).dependent(:restrict_with_error) }
  it { should have_many(:billable_occurrences).through(:billable_occurrence_rate_types) }
  it { should have_many(:subsidy_rule_rate_types).dependent(:restrict_with_error) }
  it { should have_many(:subsidy_rules).through(:subsidy_rule_rate_types) }

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
