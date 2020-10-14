# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Approval, type: :model do
  it { should have_many(:child_approvals).dependent(:destroy) }
  it { should have_many(:children).through(:child_approvals) }
  it { is_expected.to monetize(:copay) }

  it do
    should define_enum_for(:copay_frequency).with_values(
      Copays.frequencies
    ).backed_by_column_of_type(:enum)
  end

  let(:approval) { build(:approval) }
  let(:effective_date) { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }

  it 'validates effective_on as a date' do
    approval.update(effective_on: Time.zone.now)
    expect(approval.valid?).to be_truthy
    approval.effective_on = "I'm a string"
    expect(approval.valid?).to be_falsey
  end

  it 'case number can be nil' do
    approval.update(case_number: '1')
    expect(approval.valid?).to be_truthy
    approval.case_number = nil
    expect(approval.valid?).to be_truthy
  end

  it 'copay can be nil' do
    approval.update(copay: Faker::Number.decimal(l_digits: 3, r_digits: 2))
    expect(approval.valid?).to be_truthy
    approval.copay = nil
    expect(approval.valid?).to be_truthy
  end

  it 'copay frequency can be nil' do
    approval.update(copay_frequency: Copays.frequencies.keys.sample)
    expect(approval.valid?).to be_truthy
    approval.copay_frequency = nil
    expect(approval.valid?).to be_truthy
  end

  it 'effective date can be nil' do
    approval.update(effective_on: effective_date)
    expect(approval.valid?).to be_truthy
    approval.copay_frequency = nil
    expect(approval.valid?).to be_truthy
  end

  it 'expiration date can be nil' do
    approval.update(expires_on: effective_date + 1.year)
    expect(approval.valid?).to be_truthy
    approval.copay_frequency = nil
    expect(approval.valid?).to be_truthy
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:approval)).to be_valid
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer          default(0), not null
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :enum
#  effective_on    :date
#  expires_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
