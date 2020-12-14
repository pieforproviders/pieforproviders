# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildApproval, type: :model do
  it { should belong_to(:child) }
  it { should belong_to(:approval) }
  it { should belong_to(:subsidy_rule).optional }
  it { should have_many(:illinois_approval_amounts).dependent(:restrict_with_error) }
  it 'factory should be valid (default; no args)' do
    expect(build(:child_approval)).to be_valid
  end
end

# == Schema Information
#
# Table name: child_approvals
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  approval_id     :uuid             not null
#  child_id        :uuid             not null
#  subsidy_rule_id :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id      (approval_id)
#  index_child_approvals_on_child_id         (child_id)
#  index_child_approvals_on_subsidy_rule_id  (subsidy_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#
