# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
# rubocop:disable Metrics/ClassLength
class Child < UuidApplicationRecord
  before_save :find_or_create_approvals
  after_create_commit :create_default_schedule, unless: proc { |child| child.schedules.present? }
  after_save_commit :associate_rate, unless: proc { |child| child.active_previously_changed?(from: true, to: false) }

  belongs_to :business

  has_many :child_approvals, dependent: :destroy, inverse_of: :child, autosave: true
  has_many :approvals, through: :child_approvals, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :nebraska_approval_amounts, through: :child_approvals, dependent: :destroy
  has_many :service_days, dependent: :destroy
  has_many :attendances, through: :service_days, dependent: :destroy
  has_many :nebraska_dashboard_cases, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :approvals, presence: true
  validates :date_of_birth, date_param: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  # This prevents this validation from running if other validations failed; if date_of_birth has thrown an error,
  # this will try to validate with the incorrect dob even though the record has already failed
  validates :business_id,
            uniqueness: { scope: %i[first_name last_name date_of_birth] },
            unless: lambda {
              errors[:date_of_birth].present? || errors[:first_name].present? || errors[:last_name].present?
            }

  REASONS = %w[
    no_longer_in_my_care
    no_longer_receiving_subsidies
    other
  ].freeze

  validates :inactive_reason, inclusion: { in: REASONS }, allow_nil: true
  validates :last_active_date, date_param: true, unless: proc { |child| child.last_active_date_before_type_cast.nil? }
  validates :last_inactive_date,
            date_param: true,
            unless: proc { |child| child.last_inactive_date_before_type_cast.nil? }

  accepts_nested_attributes_for :approvals, :child_approvals, :schedules

  scope :active, -> { where(active: true) }
  scope :approved_for_date,
        lambda { |date|
          joins(:approvals).where("DATE_TRUNC('month', approvals.effective_on) <= ? AND 
          (DATE_TRUNC('month', approvals.expires_on) >= ? OR approvals.expires_on IS NULL)", 
          date&.beginning_of_month, date&.beginning_of_month
   )
        }
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :nebraska, -> { joins(:business).where(business: { state: 'NE' }) }

  scope :with_dashboard_case,
        lambda { |date = nil|
          date ||= Time.current
          # joins(:service_days)
          not_deleted
            .distinct
            .approved_for_date(date)
            .includes(:schedules)
            .order(:last_name)
        }

  scope :with_schedules, -> { includes(:schedules) }
  scope :with_business, -> { includes(:business) }

  delegate :county, to: :business
  delegate :user, to: :business
  delegate :state, to: :user
  delegate :timezone, to: :user

  before_save :validate_wonderschool_id

  def age(date = Time.current)
    years_since_birth = date.year - date_of_birth.year
    birthday_passed = date_of_birth.month <= date.month || date_of_birth.day <= date.day
    birthday_passed ? years_since_birth : years_since_birth - 1
  end

  def age_in_months(date = Time.current)
    years_since_birth = date.year - date_of_birth.year
    months_since_birth = date.month - date_of_birth.month
    birthday_passed = date_of_birth.day <= date.day
    birthday_passed ? (years_since_birth * 12) + months_since_birth : (years_since_birth * 12) + months_since_birth - 1
  end

  def active_approval(date)
    approvals.active_on(date).first
  end

  def active_child_approval(date)
    active_approval(date)&.child_approvals&.find_by(child: self)
  end

  def active_nebraska_approval_amount(date)
    @active_nebraska_approval_amount ||= Hash.new do |h, key|
      h[key] = nebraska_approval_amounts.active_on(key).first
    end
    @active_nebraska_approval_amount[date]
  end

  def attendance_rate(date)
    AttendanceRateCalculator.new(self, date).call
  end

  def attendance_risk(date)
    # TODO: break this out to IL like NE Services
    AttendanceRiskCalculator.new(self, date).call if state == 'IL'
  end

  def active_rate(date)
    active_child_approval(date).rate
  end

  def illinois_approval_amounts
    IllinoisApprovalAmount.where(child_approval: ChildApproval.where(child: self))
  end

  # TODO: these methods are duplicative and need to be moved to a
  # concern so child and attendance can both use them [PIE-1529]

  def total_time_scheduled_this_month(date:)
    (0..6).reduce(0) do |sum, weekday|
      sum + weekday_scheduled_duration(date.at_beginning_of_month, weekday)
    end
  end

  def weekday_scheduled_duration(date, weekday)
    schedule_for_weekday = schedules.find do |schedule|
      schedule.weekday == weekday &&
        schedule.effective_on <= date &&
        (schedule.expires_on.nil? || schedule.expires_on > date)
    end
    return 0 unless schedule_for_weekday

    schedule_for_weekday.duration * DateService.remaining_days_in_month_including_today(date: date, weekday: weekday)
  end

  def schedules_for_weekday(date, weekday)
    schedules.select do |schedule|
      schedule.weekday == weekday &&
        schedule.effective_on <= date &&
        (schedule.expires_on.nil? || schedule.expires_on > date)
    end
  end

  def eligible_full_days_by_month(date = Time.current)
    Illinois::EligibleDaysCalculator.new(date: date, child: self, full_time: true).call
  end

  def eligible_part_days_by_month(date = Time.current)
    Illinois::EligibleDaysCalculator.new(date: date, child: self, full_time: false).call
  end

  private

  def eligible_by_date?(date)
    business.eligible_by_date?(date)
  end

  def find_or_create_approvals
    self.approvals = approvals.map do |approval|
      Approval.find_or_create_by(
        case_number: approval.case_number,
        effective_on: approval.effective_on,
        expires_on: approval.expires_on
      )
    end
  end

  def create_default_schedule
    # this will run for Mon (1) - Fri (5)
    5.times do |idx|
      Schedule.create!(
        child: self,
        weekday: idx + 1,
        duration: 28_800, # seconds in 8 hours
        effective_on: approvals.first.effective_on
      )
    end
  end

  def associate_rate
    RateAssociatorJob.perform_later(id)
  end

  def validate_wonderschool_id
    self.wonderschool_id = wonderschool_id.to_i.to_s == wonderschool_id ? wonderschool_id : nil
  end
end
# rubocop:enable Metrics/ClassLength
# == Schema Information
#
# Table name: children
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE), not null
#  date_of_birth      :date             not null
#  deleted_at         :date
#  first_name         :string           not null
#  inactive_reason    :string
#  last_active_date   :date
#  last_inactive_date :date
#  last_name          :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_id        :uuid             not null
#  dhs_id             :string
#  wonderschool_id    :string
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  index_children_on_deleted_at   (deleted_at)
#  unique_children                (first_name,last_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
