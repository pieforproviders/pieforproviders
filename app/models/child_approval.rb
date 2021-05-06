# frozen_string_literal: true

# An individual child on a family's approval letter
class ChildApproval < UuidApplicationRecord
  belongs_to :child
  belongs_to :approval
  belongs_to :rate, optional: true
  has_many :illinois_approval_amounts, dependent: :restrict_with_error
  has_many :nebraska_approval_amounts, dependent: :restrict_with_error
  has_many :attendances, dependent: :restrict_with_error

  delegate :user, to: :child

  accepts_nested_attributes_for :nebraska_approval_amounts, :approval
end

# == Schema Information
#
# Table name: child_approvals
#
#  id                        :uuid             not null, primary key
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
#  nebraska_rate_id          :uuid
#  rate_id                   :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id       (approval_id)
#  index_child_approvals_on_child_id          (child_id)
#  index_child_approvals_on_nebraska_rate_id  (nebraska_rate_id)
#  index_child_approvals_on_rate_id           (rate_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (nebraska_rate_id => nebraska_rates.id)
#  fk_rails_...  (rate_id => rates.id)
#
