# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaRate, type: :model do
  it { should have_many(:child_approvals) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:effective_on) }
  it { should validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }
  it { should validate_numericality_of(:amount) }
  it { should validate_inclusion_of(:rate_type).in_array(NebraskaRate::TYPES) }
  it { should validate_inclusion_of(:region).in_array(NebraskaRate::REGIONS) }

  it_behaves_like 'licenses'

  let(:nebraska_rate) { build(:nebraska_rate) }

  it 'validates effective_on as a date' do
    nebraska_rate.update(effective_on: Time.current)
    expect(nebraska_rate.valid?).to be_truthy
    nebraska_rate.effective_on = "I'm a string"
    expect(nebraska_rate.valid?).to be_falsey
    nebraska_rate.effective_on = nil
    expect(nebraska_rate.valid?).to be_falsey
    nebraska_rate.effective_on = '2021-02-01'
    expect(nebraska_rate.valid?).to be_truthy
    nebraska_rate.effective_on = Date.new(2021, 12, 11)
    expect(nebraska_rate.valid?).to be_truthy
  end

  it 'validates expires_on as an optional date' do
    nebraska_rate.update(expires_on: Time.current)
    expect(nebraska_rate.valid?).to be_truthy
    nebraska_rate.expires_on = "I'm a string"
    expect(nebraska_rate.valid?).to be_falsey
    nebraska_rate.expires_on = nil
    expect(nebraska_rate.valid?).to be_truthy
    nebraska_rate.expires_on = '2021-02-01'
    expect(nebraska_rate.valid?).to be_truthy
    nebraska_rate.expires_on = Date.new(2021, 12, 11)
    expect(nebraska_rate.valid?).to be_truthy
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:nebraska_rate)).to be_valid
  end
end

# == Schema Information
#
# Table name: nebraska_rates
#
#  id              :uuid             not null, primary key
#  accredited_rate :boolean          default(FALSE), not null
#  amount          :decimal(, )      not null
#  county          :string
#  effective_on    :date             not null
#  expires_on      :date
#  license_type    :string           not null
#  max_age         :decimal(, )
#  name            :string           not null
#  rate_type       :string           not null
#  region          :string           not null
#  school_age      :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
