# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisApprovalAmount, type: :model do
  it { is_expected.to belong_to(:child_approval) }
  it { is_expected.to validate_presence_of(:month) }
  it { is_expected.to validate_numericality_of(:part_days_approved_per_week) }
  it { is_expected.to validate_numericality_of(:full_days_approved_per_week) }

  it 'factory should be valid (default; no args)' do
    expect(build(:illinois_approval_amount)).to be_valid
  end
end

# == Schema Information
#
# Table name: illinois_approval_amounts
#
#  id                          :uuid             not null, primary key
#  full_days_approved_per_week :integer
#  month                       :date             not null
#  part_days_approved_per_week :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  child_approval_id           :uuid             not null
#
# Indexes
#
#  index_illinois_approval_amounts_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
