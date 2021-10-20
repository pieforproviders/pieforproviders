# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { is_expected.to belong_to(:child_approval) }
  it { is_expected.to validate_numericality_of(:amount) }
  it { is_expected.to validate_presence_of(:month) }

  it 'factory should be valid (default; no args)' do
    expect(build(:payment)).to be_valid
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                :uuid             not null, primary key
#  amount            :decimal(, )      not null
#  month             :date             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  child_approval_id :uuid             not null
#
# Indexes
#
#  index_payments_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
