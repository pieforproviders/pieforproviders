# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class NebraskaApprovalAmount < UuidApplicationRecord
  belongs_to :child_approval
  validates :effective_on, presence: true
  validates :expires_on, presence: true

  scope :active_on_date,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc)
        }
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
