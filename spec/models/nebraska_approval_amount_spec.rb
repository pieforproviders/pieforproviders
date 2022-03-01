# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaApprovalAmount, type: :model do
  let(:nebraska_approval_amount) { build(:nebraska_approval_amount) }

  it { is_expected.to belong_to(:child_approval) }

  it 'factory should be valid (default; no args)' do
    expect(nebraska_approval_amount).to be_valid
  end

  it { is_expected.to validate_presence_of(:expires_on) }
  it { is_expected.to validate_presence_of(:effective_on) }

  it 'validates expires_on_after_effective_on' do
    nebraska_approval_amount.update(expires_on: 50.years.ago)
    expect(nebraska_approval_amount.errors.messages[:expires_on]).to include('must be after the effective on date')
  end
end

# == Schema Information
#
# Table name: nebraska_approval_amounts
#
#  id                   :uuid             not null, primary key
#  allocated_family_fee :decimal(, )      not null
#  deleted_at           :date
#  effective_on         :date             not null
#  expires_on           :date             not null
#  family_fee           :decimal(, )      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  child_approval_id    :uuid             not null
#
# Indexes
#
#  index_nebraska_approval_amounts_on_child_approval_id  (child_approval_id)
#  index_nebraska_approval_amounts_on_effective_on       (effective_on)
#  index_nebraska_approval_amounts_on_expires_on         (expires_on)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
