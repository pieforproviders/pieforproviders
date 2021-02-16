# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < UuidApplicationRecord
  before_save :find_or_create_approvals
  after_commit :associate_subsidy_rule

  belongs_to :business

  has_many :child_approvals, dependent: :destroy
  has_many :approvals, through: :child_approvals

  has_one :temporary_nebraska_dashboard_case, dependent: :destroy

  validates :active, inclusion: { in: [true, false] }
  validates :date_of_birth, presence: true
  validates :full_name, presence: true
  validates :full_name, uniqueness: { scope: %i[date_of_birth business_id] }

  validates :approvals, presence: true

  validates :date_of_birth, date_param: true

  accepts_nested_attributes_for :approvals

  scope :active, -> { where(active: true) }
  scope :approved_for_date, lambda { |date, timezone|
                              joins(:approvals).where('approvals.effective_on <= ? AND approvals.expires_on > ?', date.in_time_zone(timezone), date.in_time_zone(timezone))
                            }

  delegate :user, to: :business

  def state
    business.user.state
  end

  def timezone
    business.user.timezone
  end

  def active_child_approval(date)
    child_approvals.find_by(approval: approvals.active_on_date(date.in_time_zone(timezone)))
  end

  def attendances
    Attendance.where(child_approval: ChildApproval.where(child: self))
  end

  def active_subsidy_rule(date)
    active_child_approval(date).subsidy_rule
  end

  def illinois_approval_amounts
    IllinoisApprovalAmount.where(child_approval: ChildApproval.where(child: self))
  end

  def attendance_rate(from_date)
    AttendanceRateCalculator.new(self, from_date.in_time_zone(timezone)).call
  end

  def attendance_risk(from_date)
    AttendanceRiskCalculator.new(self, from_date.in_time_zone(timezone)).call
  end

  private

  def find_or_create_approvals
    self.approvals = approvals.map do |approvals|
      Approval.find_or_create_by(case_number: approvals.case_number,
                                 effective_on: approvals.effective_on,
                                 expires_on: approvals.expires_on)
    end
  end

  def associate_subsidy_rule
    SubsidyRuleAssociatorJob.perform_later(id)
  end
end

# == Schema Information
#
# Table name: children
#
#  id              :uuid             not null, primary key
#  active          :boolean          default(TRUE), not null
#  date_of_birth   :date             not null
#  full_name       :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  business_id     :uuid             not null
#  wonderschool_id :string
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
