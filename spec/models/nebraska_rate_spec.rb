# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaRate, type: :model do
  let(:nebraska_rate) { build(:nebraska_rate) }

  it { is_expected.to have_many(:child_approvals) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:effective_on) }
  it { is_expected.to validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:amount) }
  it { is_expected.to validate_inclusion_of(:rate_type).in_array(NebraskaRate::TYPES) }
  it { is_expected.to validate_inclusion_of(:region).in_array(NebraskaRate::REGIONS) }

  it_behaves_like 'licenses'

  it 'validates effective_on as a date' do
    nebraska_rate.update(effective_on: Time.current)
    expect(nebraska_rate).to be_valid
    nebraska_rate.effective_on = "I'm a string"
    expect(nebraska_rate).not_to be_valid
    nebraska_rate.effective_on = nil
    expect(nebraska_rate).not_to be_valid
    nebraska_rate.effective_on = '2021-02-01'
    expect(nebraska_rate).to be_valid
    nebraska_rate.effective_on = Date.new(2021, 12, 11)
    expect(nebraska_rate).to be_valid
  end

  it 'validates expires_on as an optional date' do
    nebraska_rate.update(expires_on: Time.current)
    expect(nebraska_rate).to be_valid
    nebraska_rate.expires_on = "I'm a string"
    expect(nebraska_rate).not_to be_valid
    nebraska_rate.expires_on = nil
    expect(nebraska_rate).to be_valid
    nebraska_rate.expires_on = '2021-02-01'
    expect(nebraska_rate).to be_valid
    nebraska_rate.expires_on = Date.new(2021, 12, 11)
    expect(nebraska_rate).to be_valid
  end

  it 'returns rates in the correct order by max age' do
    nebraska_rate.destroy!
    infant = create(:nebraska_rate, max_age: 18)
    create(:nebraska_rate, max_age: 36)
    create(:nebraska_rate, max_age: 24)
    expect(described_class.order_max_age[0]).to eq(infant)
    create(:nebraska_rate, max_age: nil)
    expect(described_class.order_max_age[0]).to eq(infant)
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
#  deleted_at      :date
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
