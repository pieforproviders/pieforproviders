# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { should belong_to(:agency) }
  it { should validate_numericality_of(:amount).is_greater_than(0.00) }
  it { is_expected.to monetize(:amount) }
  it { is_expected.to monetize(:discrepancy) }

  it 'factory should be valid (default; no args)' do
    expect(build(:payment)).to be_valid
  end

  let(:invalid_date_msg) { DateParamValidator.invalid_date_msg }

  it 'care_finished_on is a valid Date' do
    pay = build(:payment)
    pay.valid?
    expect(pay.errors[:care_finished_on]).not_to include(invalid_date_msg)
    pay.care_finished_on = nil
    pay.valid?
    expect(pay.errors[:care_finished_on]).to include(invalid_date_msg)
  end
  it 'care_started_on is a valid Date' do
    pay = build(:payment)
    pay.valid?
    expect(pay.errors[:care_started_on]).not_to include(invalid_date_msg)
    pay.care_started_on = nil
    pay.valid?
    expect(pay.errors[:care_started_on]).to include(invalid_date_msg)
  end
  it 'paid_on is a valid Date' do
    pay = build(:payment)
    pay.valid?
    expect(pay.errors[:paid_on]).not_to include(invalid_date_msg)
    pay.paid_on = nil
    pay.valid?
    expect(pay.errors[:paid_on]).to include(invalid_date_msg)
  end

  it 'discrepancy can be nil' do
    pay = create(:payment)
    pay.update(discrepancy: 10.00)
    expect(pay.valid?).to be_truthy
    pay.discrepancy = nil
    expect(pay.valid?).to be_truthy
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount_cents         :integer          default(0), not null
#  amount_currency      :string           default("USD"), not null
#  care_finished_on     :date             not null
#  care_started_on      :date             not null
#  discrepancy_cents    :integer
#  discrepancy_currency :string           default("USD")
#  paid_on              :date             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  agency_id            :uuid             not null
#
