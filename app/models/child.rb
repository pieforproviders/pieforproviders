# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < UuidApplicationRecord
  before_save :find_or_create_approvals
  after_create_commit :create_default_schedule, unless: proc { |child| child.schedules.present? }
  after_save_commit :associate_rate, unless: proc { |child| child.active_previously_changed?(from: true, to: false) }

  belongs_to :business

  has_many :child_approvals, dependent: :destroy, inverse_of: :child, autosave: true
  has_many :approvals, through: :child_approvals, dependent: :destroy
  has_many :schedules, dependent: :delete_all
  has_many :nebraska_approval_amounts, through: :child_approvals, dependent: :destroy

  has_one :temporary_nebraska_dashboard_case, dependent: :destroy

  validates :approvals, presence: true
  validates :date_of_birth, date_param: true, presence: true
  validates :full_name, presence: true
  # This prevents this validation from running if other validations failed; if date_of_birth has thrown an error,
  # this will try to validate with the incorrect dob even though the record has already failed
  validates :full_name, uniqueness: { scope: %i[date_of_birth business_id] }, unless: -> { errors }

  REASONS = %w[
    no_longer_in_my_care
    no_longer_receiving_subsidies
    other
  ].freeze

  validates :inactive_reason, inclusion: { in: REASONS }, allow_nil: true
  validates :last_active_date, date_param: true, unless: proc { |child| child.last_active_date_before_type_cast.nil? }

  accepts_nested_attributes_for :approvals, :child_approvals, :schedules

  scope :active, -> { where(active: true) }
  scope :approved_for_date, ->(date) { joins(:approvals).merge(Approval.active_on_date(date)) }
  scope :not_deleted, -> { where(deleted: false) }

  delegate :user, to: :business
  delegate :state, to: :user
  delegate :timezone, to: :user

  def active_approval(date)
    approvals.active_on_date(date).first
  end

  def active_child_approval(date)
    active_approval(date)&.child_approvals&.find_by(child: self)
  end

  def attendances
    Attendance.joins(:child_approval).where(child_approvals: { child: self })
  end

  def attendance_rate(filter_date)
    AttendanceRateCalculator.new(self, filter_date).call
  end

  def attendance_risk(filter_date)
    AttendanceRiskCalculator.new(self, filter_date).call
  end

  def active_rate(date)
    active_child_approval(date).rate
  end

  def active_nebraska_approval_amount(date)
    nebraska_approval_amounts.active_on_date(date).first
  end

  def illinois_approval_amounts
    IllinoisApprovalAmount.where(child_approval: ChildApproval.where(child: self))
  end

  # NE dashboard family_fee calculator
  def nebraska_family_fee(filter_date)
    # "feature flag" for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      format('%.2f',
             active_nebraska_approval_amount(filter_date)&.family_fee)
    else
      format('%.2f',
             temporary_nebraska_dashboard_case&.family_fee.to_f)
    end
  end

  # NE dashboard full days calculator
  def nebraska_full_days(filter_date)
    Rails.application.config.ff_ne_live_algorithms ? NebraskaFullDaysCalculator.new(self, filter_date).call : temporary_nebraska_dashboard_case&.full_days
  end

  # NE dashboard hours calculator
  def nebraska_hours(filter_date)
    # "feature flag" for using live algorithms rather than uploaded data
    Rails.application.config.ff_ne_live_algorithms ? NebraskaHoursCalculator.new(self, filter_date).call : temporary_nebraska_dashboard_case&.hours.to_f
  end

  # NE dashboard weekly used hours calculator
  def nebraska_weekly_hours_attended(filter_date)
    if Rails.application.config.ff_ne_live_algorithms
      NebraskaWeeklyHoursAttendedCalculator.new(self,
                                                filter_date).call
    else
      temporary_nebraska_dashboard_case&.hours_attended&.to_f
    end
  end

  private

  def find_or_create_approvals
    self.approvals = approvals.map do |approval|
      Approval.find_or_create_by(case_number: approval.case_number,
                                 effective_on: approval.effective_on,
                                 expires_on: approval.expires_on)
    end
  end

  def create_default_schedule
    # this will run for Mon (1) - Fri (5)
    5.times do |idx|
      Schedule.create!(
        child: self,
        weekday: idx + 1,
        start_time: '9:00am',
        end_time: '5:00pm',
        effective_on: active_child_approval(Time.current.in_time_zone(timezone)).approval.effective_on
      )
    end
  end

  def associate_rate
    RateAssociatorJob.perform_later(id)
  end
end

# == Schema Information
#
# Table name: children
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE), not null
#  date_of_birth      :date             not null
#  deleted            :boolean          default(FALSE), not null
#  enrolled_in_school :boolean
#  full_name          :string           not null
#  inactive_reason    :string
#  last_active_date   :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_id        :uuid             not null
#  dhs_id             :string
#  wonderschool_id    :string
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
