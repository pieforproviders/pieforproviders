# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < UuidApplicationRecord
  after_commit :associate_subsidy_rule

  belongs_to :business

  has_many :child_approvals, dependent: :destroy
  has_many :approvals, through: :child_approvals

  validates :active, inclusion: { in: [true, false] }
  validates :date_of_birth, presence: true
  validates :full_name, presence: true
  validates :full_name, uniqueness: { scope: %i[date_of_birth business_id] }

  validates :approvals, presence: true

  validates :date_of_birth, date_param: true

  accepts_nested_attributes_for :approvals

  scope :active, -> { where(active: true) }

  # TODO: Figure out how to merge this scope correctly
  scope :with_current_approval, -> { joins(:approvals).where('approvals.effective_on <= ? AND approvals.expires_on > ?', Date.current, Date.current) }

  delegate :user, to: :business

  def current_approval
    approvals.current.first
  end

  def current_child_approval
    child_approvals.find_by(approval: current_approval)
  end

  def current_subsidy_rule
    current_child_approval.subsidy_rule
  end

  def attendance_risk
    'at_risk'
  end

  def attendance_rate
    0.46
  end

  def guaranteed_revenue
    1045.32
  end

  def potential_revenue
    2022.14
  end

  def max_approved_revenue
    2025.12
  end

  private

  def associate_subsidy_rule
    SubsidyRuleAssociator.new(self).call
  end
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  business_id   :uuid             not null
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
