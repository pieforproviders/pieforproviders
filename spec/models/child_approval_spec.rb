# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildApproval, type: :model do
  it { is_expected.to belong_to(:child) }
  it { is_expected.to belong_to(:approval) }
  it { is_expected.to belong_to(:rate).optional }
  it { is_expected.to have_many(:illinois_approval_amounts).dependent(:destroy) }
  it { is_expected.to have_many(:nebraska_approval_amounts).dependent(:destroy) }
  it { is_expected.to have_many(:attendances).dependent(:destroy) }

  it 'factory should be valid (default; no args)' do
    expect(build(:child_approval)).to be_valid
  end
end

# == Schema Information
#
# Table name: child_approvals
#
#  id                        :uuid             not null, primary key
#  authorized_weekly_hours   :integer
#  enrolled_in_school        :boolean
#  full_days                 :integer
#  hours                     :decimal(, )
#  rate_type                 :string
#  special_needs_daily_rate  :decimal(, )
#  special_needs_hourly_rate :decimal(, )
#  special_needs_rate        :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  approval_id               :uuid             not null
#  child_id                  :uuid             not null
#  rate_id                   :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id  (approval_id)
#  index_child_approvals_on_child_id     (child_id)
#  index_child_approvals_on_rate         (rate_type,rate_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#
