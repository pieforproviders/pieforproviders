# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class NebraskaApprovalAmount < UuidApplicationRecord
  belongs_to :child_approval
  validates :effective_on, presence: true
  validates :expires_on, presence: true
  validate :expires_on_after_effective_on

  scope :active_on, ->(date) { where(effective_on: ..date, expires_on: [nil, date..]).order(updated_at: :desc) }

  def family_fee
    Money.from_amount(super)
  end

  def expires_on_after_effective_on
    return if expires_on.blank? || effective_on.blank?

    errors.add(:expires_on, 'must be after the effective on date') if expires_on < effective_on
  end
end

# == Schema Information
#
# Table name: nebraska_approval_amounts
#
#  id                :uuid             not null, primary key
#  deleted_at        :date
#  effective_on      :date             not null
#  expires_on        :date             not null
#  family_fee        :decimal(, )      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  child_approval_id :uuid             not null
#
# Indexes
#
#  index_nebraska_approval_amounts_on_child_approval_id  (child_approval_id)
#  index_nebraska_approval_amounts_on_effective_on       (effective_on)
#  index_nebraska_approval_amounts_on_expires_on         (expires_on)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
