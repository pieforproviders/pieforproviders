# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisRate do
  let(:illinois_rate) { build(:illinois_rate) }

  it { is_expected.to have_many(:child_approvals) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:region) }
  it { is_expected.to validate_presence_of(:effective_on) }
  it { is_expected.to validate_presence_of(:rate_type) }
  it { is_expected.to validate_numericality_of(:age_bucket).is_greater_than_or_equal_to(0.00) }

  it_behaves_like 'licenses'

  it 'validates effective_on as a date' do
    illinois_rate.update(effective_on: Time.current)
    expect(illinois_rate).to be_valid
    illinois_rate.effective_on = "I'm a string"
    expect(illinois_rate).not_to be_valid
    illinois_rate.effective_on = nil
    expect(illinois_rate).not_to be_valid
    illinois_rate.effective_on = '2021-02-01'
    expect(illinois_rate).to be_valid
    illinois_rate.effective_on = Date.new(2021, 12, 11)
    expect(illinois_rate).to be_valid
  end

  it 'validates expires_on as an optional date' do
    illinois_rate.update(expires_on: Time.current)
    expect(illinois_rate).to be_valid
    illinois_rate.expires_on = "I'm a string"
    expect(illinois_rate).not_to be_valid
    illinois_rate.expires_on = nil
    expect(illinois_rate).to be_valid
    illinois_rate.expires_on = '2021-02-01'
    expect(illinois_rate).to be_valid
    illinois_rate.expires_on = Date.new(2021, 12, 11)
    expect(illinois_rate).to be_valid
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:illinois_rate)).to be_valid
  end
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                :uuid             not null, primary key
#  age_bucket        :decimal(, )      default(0.0)
#  amount            :decimal(, )      not null
#  deleted_at        :date
#  effective_on      :date             not null
#  expires_on        :date
#  license_type      :string           default("licensed_family_home"), not null
#  name              :string           default("Rule Name Filler"), not null
#  rate_type         :string           not null
#  region            :string           default(" "), not null
#  silver_percentage :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_illinois_rates_on_effective_on  (effective_on)
#  index_illinois_rates_on_expires_on    (expires_on)
#
