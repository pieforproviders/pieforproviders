# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Approval, type: :model do
  it { is_expected.to have_many(:child_approvals).dependent(:destroy) }
  it { is_expected.to have_many(:children).through(:child_approvals) }
  it { is_expected.to monetize(:copay) }

  let(:approval) { build(:approval) }
  let(:effective_date) { (Time.current - 6.months).to_date }

  it 'validates effective_on as a date' do
    approval.update(effective_on: Time.current)
    expect(approval.valid?).to be_truthy
    approval.effective_on = "I'm a string"
    expect(approval.valid?).to be_falsey
    approval.effective_on = nil
    expect(approval.valid?).to be_falsey
    approval.effective_on = '2021-02-01'
    expect(approval.valid?).to be_truthy
    approval.effective_on = Date.new(2021, 12, 11)
    expect(approval.valid?).to be_truthy
  end

  it 'validates expires_on as an optional date' do
    approval.update(expires_on: Time.current)
    expect(approval.valid?).to be_truthy
    approval.expires_on = "I'm a string"
    expect(approval.valid?).to be_falsey
    approval.expires_on = nil
    expect(approval.valid?).to be_truthy
    approval.expires_on = '2021-02-01'
    expect(approval.valid?).to be_truthy
    approval.expires_on = Date.new(2021, 12, 11)
    expect(approval.valid?).to be_truthy
  end

  it 'case number can be nil' do
    approval.update(case_number: '1')
    expect(approval.valid?).to be_truthy
    approval.case_number = nil
    expect(approval.valid?).to be_truthy
  end

  it 'copay can be nil' do
    approval.update(copay: Faker::Number.between(from: 1000, to: 10_000))
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

  it 'returns the timezone from the first child on the record' do
    approval = create(:approval) # this creates children along with the approval, which build does not do
    expect(approval.timezone).to eq(approval.children.first.timezone)
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:approval)).to be_valid
  end

  describe '#child_with_most_scheduled_hours' do
    before { approval.save! }

    it 'returns the child with the most scheduled hours' do
      child_with_more_hours = create(:child, approvals: [approval])
      create(:child, approvals: [approval], schedules: [create(:schedule)])
      expect(approval.child_with_most_scheduled_hours(Time.current.in_time_zone(child_with_more_hours.timezone)))
        .to eq(child_with_more_hours)
    end
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :string
#  effective_on    :date
#  expires_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
