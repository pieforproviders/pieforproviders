# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaApprovalAmount, type: :model do
  it { is_expected.to belong_to(:child_approval) }

  it 'factory should be valid (default; no args)' do
    expect(build(:nebraska_approval_amount)).to be_valid
  end
end
