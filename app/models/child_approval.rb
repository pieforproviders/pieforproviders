# frozen_string_literal: true

# An individual child on a family's approval letter
class ChildApproval < UuidApplicationRecord
  belongs_to :child
  belongs_to :approval
  belongs_to :illinois_rate, optional: true
  has_many :illinois_approval_amounts, dependent: :destroy
  has_many :nebraska_approval_amounts, dependent: :destroy
  has_many :attendances, dependent: :destroy

  delegate :user, to: :child

  accepts_nested_attributes_for :nebraska_approval_amounts, :approval
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
#  special_needs_daily_rate  :decimal(, )
#  special_needs_hourly_rate :decimal(, )
#  special_needs_rate        :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  approval_id               :uuid             not null
#  child_id                  :uuid             not null
#  illinois_rate_id          :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id       (approval_id)
#  index_child_approvals_on_child_id          (child_id)
#  index_child_approvals_on_illinois_rate_id  (illinois_rate_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (illinois_rate_id => illinois_rates.id)
#
