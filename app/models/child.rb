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
  has_many :schedules, dependent: :delete_all
  has_many :nebraska_approval_amounts, through: :child_approvals, dependent: :destroy
  has_many :service_days, dependent: :destroy
  has_many :attendances, through: :service_days, dependent: :destroy

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
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :nebraska, -> { joins(:business).where(business: { state: 'NE' }) }

  delegate :county, to: :business
  delegate :user, to: :business
  delegate :state, to: :user
  delegate :timezone, to: :user

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
    approvals.active_on_date(date).first
  end

  def active_child_approval(date)
    active_approval(date)&.child_approvals&.find_by(child: self)
  end

  def absences(date)
    if Rails.application.config.ff_ne_live_algorithms
      attendances.for_month(date).absences.length
    else
      temporary_nebraska_dashboard_case&.absences
    end
  end

  def attendance_rate(date)
    AttendanceRateCalculator.new(self, date).call
  end

  def attendance_risk(date)
    if state == 'IL'
      AttendanceRiskCalculator.new(self, date).call
    elsif Rails.application.config.ff_ne_live_algorithms
      risk_calculation(date)
    else
      temporary_nebraska_dashboard_case&.attendance_risk
    end
  end

  def risk_calculation(date)
    return 'not_enough_info' if date <= minimum_days_to_calculate(date)

    estimated_revenue = estimated_remaining_revenue(date)
    scheduled_revenue = total_scheduled_revenue(date)
    ratio = (estimated_revenue.to_f - scheduled_revenue.to_f) / scheduled_revenue.to_f
    risk_ratio_label(ratio)
  end

  def risk_ratio_label(ratio)
    if ratio <= -0.2
      'at_risk'
    elsif ratio > -0.2 && ratio <= 0.2
      'on_track'
    else
      'ahead_of_schedule'
    end
  end

  def minimum_days_to_calculate(date)
    date.in_time_zone(timezone).at_beginning_of_month + 9.days
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
  def nebraska_family_fee(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      return 0 unless self == active_approval(date).child_with_most_scheduled_hours(date)

      active_nebraska_approval_amount(date)&.family_fee || 0.00
    else
      temporary_nebraska_dashboard_case&.family_fee.to_f
    end
  end

  # NE dashboard earned_revenue calculator
  def nebraska_earned_revenue(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      [(earned_revenue_as_of_date(date) - nebraska_family_fee(date)), 0.0].max
    else
      temporary_nebraska_dashboard_case&.earned_revenue&.to_f || 0.0
    end
  end

  # NE dashboard estimated_revenue calculator
  def nebraska_estimated_revenue(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      [(estimated_remaining_revenue(date) - nebraska_family_fee(date)), 0.0].max
    else
      temporary_nebraska_dashboard_case&.estimated_revenue&.to_f || 0.0
    end
  end

  def earned_revenue_as_of_date(date)
    (absence_revenue(date) + attendance_revenue(date))
  end

  def attendance_revenue(date)
    non_absences = attendances&.non_absences&.for_month(date)
    return 0 unless non_absences

    non_absences.pluck(:earned_revenue).sum
  end

  def absence_revenue(date)
    absences, covid_absences = attendances.absences.for_month(date).order(earned_revenue: :desc).partition do |absence|
      absence.absence == 'absence'
    end
    # only five absences are allowed per month in Nebraska
    absences.take(5).pluck(:earned_revenue).sum + covid_absences.pluck(:earned_revenue).sum
  end

  def estimated_remaining_revenue(date)
    (earned_revenue_as_of_date(date) + remaining_scheduled_revenue(date))
  end

  def hours_by_duration(duration)
    if duration <= (5.hours + 45.minutes)
      duration
    elsif duration > 10.hours && duration <= 18.hours
      duration - 10.hours
    elsif duration > 18.hours
      8.hours
    else
      0.minutes
    end
  end

  def total_scheduled_revenue(date)
    (0..6).reduce(0) do |sum, weekday|
      sum + weekday_scheduled_rate_including_today(date.at_beginning_of_month, weekday)
    end
  end

  def remaining_scheduled_revenue(date)
    (0..6).reduce(0) do |sum, weekday|
      if attendances.for_day(date).present? && weekday == date.wday
        sum + weekday_scheduled_rate_excluding_today(date, weekday)
      else
        sum + weekday_scheduled_rate_including_today(date, weekday)
      end
    end
  end

  # TODO: these methods are duplicative and need to be moved to a
  # concern so child and attendance can both use them [PIE-1529]

  def weekday_scheduled_revenue(date, weekday)
    schedule_for_weekday = schedule(date, weekday)
    return 0 unless schedule_for_weekday

    if active_child_approval(date).special_needs_rate
      ne_special_needs_revenue(date, schedule_for_weekday)
    else
      ne_base_revenue(date, schedule_for_weekday)
    end
  end

  def weekday_scheduled_rate_including_today(date, weekday)
    weekday_scheduled_revenue(date, weekday) * DateService.remaining_days_in_month_including_today(date, weekday)
  end

  def weekday_scheduled_rate_excluding_today(date, weekday)
    weekday_scheduled_revenue(date, weekday) * (DateService.remaining_days_in_month_including_today(date, weekday) - 1)
  end

  def total_time_scheduled_this_month(date)
    (0..6).reduce(0) do |sum, weekday|
      sum + weekday_scheduled_duration(date.at_beginning_of_month, weekday)
    end
  end

  def weekday_scheduled_duration(date, weekday)
    schedule_for_weekday = schedule(date, weekday)
    return 0 unless schedule_for_weekday

    schedule_for_weekday.duration * DateService.remaining_days_in_month_including_today(date, weekday)
  end

  def schedule(date, weekday)
    schedules.active_on_date(date).for_weekday(weekday).first
  end

  def ne_hours(date, schedule_for_weekday)
    # TODO: this is super sloppy because this shouldn't be a service class
    # but we haven't refactored these to procedures yet
    Nebraska::HoursCalculator.new(
      child: self,
      date: date,
      scope: :for_month
    ).round_hourly_to_quarters(schedule_for_weekday.duration)
  end

  def ne_days(date, schedule_for_weekday)
    # TODO: this is super sloppy because this shouldn't be a service class
    # but we haven't refactored these to procedures yet
    Nebraska::FullDaysCalculator.new(
      child: self,
      date: date,
      scope: :for_month
    ).calculate_full_days_based_on_duration(schedule_for_weekday.duration)
  end

  # TODO: open question - does qris bump impact this rate?
  def ne_special_needs_revenue(date, schedule_for_weekday)
    (ne_hours(date, schedule_for_weekday) * active_child_approval(date).special_needs_hourly_rate) +
      (ne_days(date, schedule_for_weekday) * active_child_approval(date).special_needs_daily_rate)
  end

  def ne_base_revenue(date, schedule_for_weekday)
    (ne_hours(date, schedule_for_weekday) * ne_hourly_rate(date) * business.ne_qris_bump) +
      (ne_days(date, schedule_for_weekday) * ne_daily_rate(date) * business.ne_qris_bump)
  end

  def ne_hourly_rate(date)
    # TODO: License Types - possibly post-new-data-model
    ne_rates(date).hourly.first&.amount || 0
  end

  def ne_daily_rate(date)
    # TODO: License Types - possibly post-new-data-model
    ne_rates(date).daily.first&.amount || 0
  end

  def ne_rates(date)
    NebraskaRate
      .active_on_date(date)
      .where(school_age: active_child_approval(date).enrolled_in_school || false)
      .where('max_age >= ? OR max_age IS NULL', age_in_months(date))
      .where(region: ne_region)
      .where(accredited_rate: business.accredited)
      .order_max_age
  end

  # rubocop:disable Metrics/MethodLength
  def ne_region
    if business.license_type == 'license_exempt_home'
      if %w[Lancaster Dakota].include?(business.county)
        'Lancaster-Dakota'
      elsif %(Douglas Sarpy).include?(business.county)
        'Douglas-Sarpy'
      else
        'Other'
      end
    elsif business.license_type == 'family_in_home'
      'All'
    else
      %w[Lancaster Dakota Douglas Sarpy].include?(business.county) ? 'LDDS' : 'Other'
    end
  end
  # rubocop:enable Metrics/MethodLength

  # NE dashboard full days calculator
  def nebraska_full_days(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      Nebraska::FullDaysCalculator.new(
        child: self,
        date: date,
        scope: :for_month
      ).call
    else
      temporary_nebraska_dashboard_case&.full_days
    end
  end

  # NE dashboard remaining full days per approval period
  def nebraska_full_days_remaining(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      return 0 unless active_child_approval(date).full_days

      active_child_approval(date).full_days - Nebraska::FullDaysCalculator.new(
        child: self,
        date: date,
        scope: nil
      ).call
    else
      'N/A'
    end
  end

  # NE dashboard hours calculator
  def nebraska_hours(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      Nebraska::HoursCalculator.new(
        child: self,
        date: date,
        scope: :for_month
      ).call
    else
      temporary_nebraska_dashboard_case&.hours.to_f
    end
  end

  # NE dashboard remaining hours per approval period
  def nebraska_hours_remaining(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      return 0 unless active_child_approval(date).hours

      active_child_approval(date).hours - Nebraska::HoursCalculator.new(
        child: self,
        date: date,
        scope: nil
      ).call
    else
      temporary_nebraska_dashboard_case&.hours.to_f
    end
  end

  # NE dashboard weekly used hours calculator
  def nebraska_weekly_hours_attended(date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      Nebraska::WeeklyHoursAttendedCalculator.new(self, date).call
    else
      temporary_nebraska_dashboard_case&.hours_attended&.to_f&.to_s
    end
  end

  private

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
        effective_on: active_child_approval(Time.current).approval.effective_on
      )
    end
  end

  def associate_rate
    RateAssociatorJob.perform_later(id)
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
