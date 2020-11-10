# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildApprovalRateType, type: :model do
  it { should belong_to(:rate_type) }
  it { should belong_to(:child_approval) }
  it 'factory should be valid (default; no args)' do
    expect(build(:child_approval_rate_type)).to be_valid
  end
end

# == Schema Information
#
# Table name: child_approval_rate_types
#
#  id                :uuid             not null, primary key
#  approved_amount   :decimal(, )
#  child_approval_id :uuid
#  rate_type_id      :uuid             not null
#
# Indexes
#
#  index_child_approval_rate_types_on_child_approval_id  (child_approval_id)
#  index_child_approval_rate_types_on_rate_type_id       (rate_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#  fk_rails_...  (rate_type_id => rate_types.id)
#
