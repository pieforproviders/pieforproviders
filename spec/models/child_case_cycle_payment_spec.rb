# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildCaseCyclePayment, type: :model do
  it { should belong_to(:child_case_cycle) }
  it { should belong_to(:payment) }

  it { should validate_numericality_of(:amount).is_greater_than(0) }
  it { is_expected.to monetize(:amount) }
  it { is_expected.to monetize(:discrepancy) }

  it 'factory should be valid (default; no args)' do
    expect(build(:child_case_cycle_payment)).to be_valid
  end

  it 'discrepancy can be nil' do
    ccc_pay = create(:child_case_cycle_payment)
    ccc_pay.update(discrepancy: 10.00)
    expect(ccc_pay.valid?).to be_truthy
    ccc_pay.discrepancy = nil
    expect(ccc_pay.valid?).to be_truthy
  end
end

# == Schema Information
#
# Table name: child_case_cycle_payments
#
#  id                   :uuid             not null, primary key
#  amount_cents         :integer          default(0), not null
#  amount_currency      :string           default("USD"), not null
#  discrepancy_cents    :integer
#  discrepancy_currency :string           default("USD")
#  slug                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  child_case_cycle_id  :uuid             not null
#  payment_id           :uuid             not null
#
# Indexes
#
#  index_child_case_cycle_payments_on_child_case_cycle_id  (child_case_cycle_id)
#  index_child_case_cycle_payments_on_payment_id           (payment_id)
#  index_child_case_cycle_payments_on_slug                 (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_case_cycle_id => child_case_cycles.id)
#  fk_rails_...  (payment_id => payments.id)
#
