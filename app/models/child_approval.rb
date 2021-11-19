# frozen_string_literal: true

# An individual child on a family's approval letter
class ChildApproval < UuidApplicationRecord
  belongs_to :child
  belongs_to :approval
  belongs_to :rate, polymorphic: true, optional: true
  has_many :illinois_approval_amounts, dependent: :destroy
  has_many :nebraska_approval_amounts, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :service_days, -> { distinct }, through: :attendances

  delegate :user, to: :child
  delegate :business, to: :child
  delegate :effective_on, to: :approval
  delegate :expires_on, to: :approval
  delegate :case_number, to: :approval

  accepts_nested_attributes_for :nebraska_approval_amounts, :approval
end

# == Schema Information
#
# Table name: child_approvals
#
#  id                        :uuid             not null, primary key
#  authorized_weekly_hours   :integer
#  deleted_at                :date
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
