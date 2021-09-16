# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisRate, type: :model do
  it { is_expected.to have_many(:child_approvals) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:max_age) }
  it { is_expected.to validate_presence_of(:county) }
  it { is_expected.to validate_presence_of(:effective_on) }
  it { is_expected.to validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:bronze_percentage) }
  it { is_expected.to validate_numericality_of(:full_day_rate) }
  it { is_expected.to validate_numericality_of(:gold_percentage) }
  it { is_expected.to validate_numericality_of(:part_day_rate) }
  it { is_expected.to validate_numericality_of(:silver_percentage) }

  it_behaves_like 'licenses'

  let(:illinois_rate) { build(:illinois_rate) }

  it 'validates effective_on as a date' do
    illinois_rate.update(effective_on: Time.current)
    expect(illinois_rate.valid?).to be_truthy
    illinois_rate.effective_on = "I'm a string"
    expect(illinois_rate.valid?).to be_falsey
    illinois_rate.effective_on = nil
    expect(illinois_rate.valid?).to be_falsey
    illinois_rate.effective_on = '2021-02-01'
    expect(illinois_rate.valid?).to be_truthy
    illinois_rate.effective_on = Date.new(2021, 12, 11)
    expect(illinois_rate.valid?).to be_truthy
  end

  it 'validates expires_on as an optional date' do
    illinois_rate.update(expires_on: Time.current)
    expect(illinois_rate.valid?).to be_truthy
    illinois_rate.expires_on = "I'm a string"
    expect(illinois_rate.valid?).to be_falsey
    illinois_rate.expires_on = nil
    expect(illinois_rate.valid?).to be_truthy
    illinois_rate.expires_on = '2021-02-01'
    expect(illinois_rate.valid?).to be_truthy
    illinois_rate.expires_on = Date.new(2021, 12, 11)
    expect(illinois_rate.valid?).to be_truthy
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:illinois_rate)).to be_valid
  end
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                   :uuid             not null, primary key
#  attendance_threshold :decimal(, )
#  bronze_percentage    :decimal(, )
#  county               :string           default(" "), not null
#  effective_on         :date             default(Thu, 02 Sep 2021), not null
#  expires_on           :date
#  full_day_rate        :decimal(, )
#  gold_percentage      :decimal(, )
#  license_type         :string           default("licensed_family_home"), not null
#  max_age              :decimal(, )      default(0.0), not null
#  name                 :string           default("Rule Name Filler"), not null
#  part_day_rate        :decimal(, )
#  silver_percentage    :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
