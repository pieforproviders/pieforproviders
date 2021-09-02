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

  def attendances
    Attendance.joins(:child_approval).where(child_approvals: { child: self })
  end

  def absences(filter_date)
    if Rails.application.config.ff_ne_live_algorithms
      attendances.for_month(filter_date).absences.length
    else
      temporary_nebraska_dashboard_case&.absences
    end
  end

  def attendance_rate(filter_date)
    AttendanceRateCalculator.new(self, filter_date).call
  end

  def attendance_risk(filter_date)
    if state == 'IL'
      AttendanceRiskCalculator.new(self, filter_date).call
    elsif Rails.application.config.ff_ne_live_algorithms
      risk_calculation(filter_date)
    else
      temporary_nebraska_dashboard_case&.attendance_risk
    end
  end

  def risk_calculation(filter_date)
    scheduled_revenue = remaining_scheduled_revenue(filter_date.in_time_zone(timezone).at_beginning_of_month)
    estimated_revenue = nebraska_estimated_revenue(filter_date)
    ratio = (estimated_revenue - scheduled_revenue) / scheduled_revenue.to_f
    if ratio <= -0.2
      'at_risk'
    elsif ratio > -0.2 && ratio <= 0.2
      'on_track'
    else
      'ahead_of_schedule'
    end
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
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      family_fee = active_nebraska_approval_amount(filter_date)&.family_fee
      family_fee || 0.00
    else
      temporary_nebraska_dashboard_case&.family_fee.to_f
    end
  end

  # NE dashboard earned_revenue calculator
  def nebraska_earned_revenue(filter_date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      revenue_less_family_fee(filter_date)
    else
      temporary_nebraska_dashboard_case&.earned_revenue&.to_f || 0.0
    end
  end

  # NE dashboard estimated_revenue calculator
  def nebraska_estimated_revenue(filter_date)
    # feature flag for using live algorithms rather than uploaded data
    if Rails.application.config.ff_ne_live_algorithms
      estimated_revenue_less_family_fee(filter_date)
    else
      temporary_nebraska_dashboard_case&.estimated_revenue&.to_f || 0.0
    end
  end

  def revenue_less_family_fee(filter_date)
    [(absence_revenue(filter_date) + attendance_revenue(filter_date) - active_nebraska_approval_amount(filter_date)&.family_fee.to_f), 0.0].max
  end

  def attendance_revenue(filter_date)
    attendances.non_absences.for_month(filter_date).pluck(:earned_revenue).sum
  end

  def absence_revenue(filter_date)
    absences, covid_absences = attendances.absences.for_month(filter_date).order(earned_revenue: :desc).partition { |absence| absence.absence == 'absence' }
    absences.take(5).pluck(:earned_revenue).sum + covid_absences.pluck(:earned_revenue).sum # only five absences are allowed per month in Nebraska
  end

  def estimated_revenue_less_family_fee(filter_date)
    [(revenue_less_family_fee(filter_date) + remaining_scheduled_revenue(filter_date)), 0.0].max
  end

  def remaining_scheduled_revenue(filter_date)
    (0..6).reduce(0) do |sum, weekday|
      sum + weekday_scheduled_rate(filter_date, weekday)
    end
  end

  # TODO: these methods are duplicative and need to be moved to a concern so child and attendance can both use them [PIE-1529]

  def weekday_scheduled_rate(filter_date, weekday)
    schedule_for_weekday = schedule(filter_date, weekday)
    return 0 unless schedule_for_weekday

    num_remaining_this_month = (filter_date.to_date..filter_date.to_date.at_end_of_month).count { |day| weekday == day.wday }
    return 0 unless num_remaining_this_month.positive?

    daily_revenue = if active_child_approval(filter_date).special_needs_rate
                      ne_special_needs_revenue(filter_date, schedule_for_weekday)
                    else
                      ne_base_revenue(filter_date, schedule_for_weekday)
                    end
    daily_revenue * num_remaining_this_month
  end

  def schedule(filter_date, weekday)
    schedules.active_on_date(filter_date).for_weekday(weekday).first
  end

  def ne_hours(filter_date, schedule_for_weekday)
    # TODO: this is super sloppy because this shouldn't be a service class but we haven't refactored these to procedures yet
    scheduled_time = Tod::Shift.new(schedule_for_weekday.start_time, schedule_for_weekday.end_time).duration
    NebraskaHoursCalculator.new(self, filter_date).round_hourly_to_quarters(scheduled_time.seconds)
  end

  def ne_days(filter_date, schedule_for_weekday)
    # TODO: this is super sloppy because this shouldn't be a service class but we haven't refactored these to procedures yet
    scheduled_time = Tod::Shift.new(schedule_for_weekday.start_time, schedule_for_weekday.end_time).duration
    NebraskaFullDaysCalculator.new(self, filter_date).calculate_full_days_based_on_duration(scheduled_time.seconds)
  end

  # TODO: open question - does qris bump impact this rate?
  def ne_special_needs_revenue(filter_date, schedule_for_weekday)
    (ne_hours(filter_date, schedule_for_weekday) * active_child_approval(filter_date).special_needs_hourly_rate) +
      (ne_days(filter_date, schedule_for_weekday) * active_child_approval(filter_date).special_needs_daily_rate)
  end

  def ne_base_revenue(filter_date, schedule_for_weekday)
    (ne_hours(filter_date, schedule_for_weekday) * ne_hourly_rate(filter_date) * business.ne_qris_bump) +
      (ne_days(filter_date, schedule_for_weekday) * ne_daily_rate(filter_date) * business.ne_qris_bump)
  end

  def ne_hourly_rate(filter_date)
    # TODO: License Types - possibly post-new-data-model
    ne_rates(filter_date).hourly.first&.amount || 0
  end

  def ne_daily_rate(filter_date)
    # TODO: License Types - possibly post-new-data-model
    ne_rates(filter_date).daily.first&.amount || 0
  end

  def ne_rates(filter_date)
    NebraskaRate
      .active_on_date(filter_date)
      .where(school_age: active_child_approval(filter_date).enrolled_in_school || false)
      .where('max_age >= ? OR max_age IS NULL', age_in_months(filter_date))
      .where(region: ne_region)
      .where(accredited_rate: business.accredited)
      .order_max_age
  end

  def ne_region
    %w[Lancaster Dakota Douglas Sarpy].include?(business.county) ? 'LDDS' : 'Other'
  end

  # NE dashboard full days calculator
  def nebraska_full_days(filter_date)
    # feature flag for using live algorithms rather than uploaded data
    Rails.application.config.ff_ne_live_algorithms ? NebraskaFullDaysCalculator.new(self, filter_date).call : temporary_nebraska_dashboard_case&.full_days
  end

  # NE dashboard hours calculator
  def nebraska_hours(filter_date)
    # feature flag for using live algorithms rather than uploaded data
    Rails.application.config.ff_ne_live_algorithms ? NebraskaHoursCalculator.new(self, filter_date).call : temporary_nebraska_dashboard_case&.hours.to_f
  end

  # NE dashboard weekly used hours calculator
  def nebraska_weekly_hours_attended(filter_date)
    # feature flag for using live algorithms rather than uploaded data
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
# rubocop:enable Metrics/ClassLength

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
