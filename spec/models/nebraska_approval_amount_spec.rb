# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaApprovalAmount, type: :model do
  it { is_expected.to belong_to(:child_approval) }

  it 'factory should be valid (default; no args)' do
    expect(build(:nebraska_approval_amount)).to be_valid
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
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
