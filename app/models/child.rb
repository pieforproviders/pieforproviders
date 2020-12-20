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

  def attendances
    Attendance.where(child_approval: ChildApproval.where(child: self))
  end

  def current_subsidy_rule
    current_child_approval.subsidy_rule
  end

  def illinois_attendance_risk
    'at_risk'
  end

  def illinois_approval_amounts
    IllinoisApprovalAmount.where(child_approval: ChildApproval.where(child: self))
  end

  def illinois_attendance_rate(from = DateTime.now.in_time_zone(business.user.timezone).at_beginning_of_month)
    calculate_illinois_attendance_rate(from.in_time_zone(business.user.timezone))
  end

  def illinois_guaranteed_revenue
    1045.32
  end

  def illinois_potential_revenue
    2022.14
  end

  def illinois_max_approved_revenue
    2025.12
  end

  private

  def associate_subsidy_rule
    SubsidyRuleAssociatorJob.perform_later(id)
  end

  def calculate_illinois_attendance_rate(date)
    return 0 unless illinois_family_days_approved(date).positive?

    (illinois_family_days_attended(date).to_f / illinois_family_days_approved(date)).round(3)
  end

  def illinois_family_days_approved(date)
    days = 0
    current_approval.children.each { |child| days += sum_approvals(child, date) }
    days
  end

  def illinois_family_days_attended(date)
    days = 0
    current_approval.children.each { |child| days += sum_attendances(child, date) }
    days
  end

  def sum_approvals(child, date)
    approval_amount = child.illinois_approval_amounts.find_by('month BETWEEN ? AND ?', date.at_beginning_of_month, date.at_end_of_month)
    return 0 unless approval_amount

    [
      approval_amount.part_days_approved_per_week * weeks_this_month(date),
      approval_amount.full_days_approved_per_week * weeks_this_month(date)
    ].sum
  end

  def sum_attendances(child, date)
    attendances = child.attendances.for_month(date)
    return 0 unless attendances

    [
      attendances.illinois_part_days.count,
      attendances.illinois_full_days.count,
      attendances.illinois_full_plus_part_days.count * 2,
      attendances.illinois_full_plus_full_days.count * 2
    ].sum
  end

  def weeks_this_month(from)
    (from.to_date.all_month.count / 7.0).ceil
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
