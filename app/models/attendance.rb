# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
# rubocop:disable Metrics/ClassLength
class Attendance < UuidApplicationRecord
  before_validation :round_check_in, :round_check_out
  before_validation :calc_total_time_in_care, if: :child_approval
  before_validation :calc_earned_revenue, if: :child_approval

  belongs_to :child_approval

  # Rails 6.2 will be returning an activesupport duration object for interval type fields
  # this uses the new behavior in advance of that release
  attribute :total_time_in_care, :interval

  validates :check_in, time_param: true, presence: true
  validates :check_out, time_param: true, unless: proc { |attendance| attendance.check_out_before_type_cast.nil? }
  validate :check_out_after_check_in
  validate :prevent_creation_of_absence_without_schedule

  ABSENCE_TYPES = %w[
    absence
    covid_absence
  ].freeze

  validates :absence, inclusion: { in: ABSENCE_TYPES }, allow_nil: true

  scope :for_month, lambda { |month = nil|
    month ||= Time.current
    where('check_in BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month)
  }
  scope :for_week, lambda { |week = nil|
    week ||= Time.current
    where('check_in BETWEEN ? AND ?', week.at_beginning_of_week(:sunday), week.at_end_of_week(:saturday))
  }
  
  scope :for_day, lambda { |day = nil|
    day ||= Time.current
    where('check_in BETWEEN ? AND ?', day.at_beginning_of_day, day.at_end_of_day)
  }

  scope :absences, -> { where.not(absence: nil) }
  scope :non_absences, -> { where(absence: nil) }

  scope :illinois_part_days, -> { where('total_time_in_care < ?', '5 hours') }
  scope :illinois_full_days, -> { where('total_time_in_care BETWEEN ? AND ?', '5 hours', '12 hours') }
  scope :illinois_full_plus_part_days, -> { where('total_time_in_care > ? AND total_time_in_care < ?', '12 hours', '17 hours') }
  scope :illinois_full_plus_full_days, -> { where('total_time_in_care BETWEEN ? AND ?', '17 hours', '24 hours') }

  delegate :business, to: :child_approval
  delegate :user, to: :child_approval
  delegate :child, to: :child_approval
  delegate :state, to: :child
  delegate :county, to: :child
  delegate :timezone, to: :user

  private

  def round_check_in
    return unless check_in

    self.check_in = Time.at(check_in - check_in.sec).in_time_zone(timezone)
  end

  def round_check_out
    return unless check_out

    self.check_out = Time.at(check_out - check_out.sec).in_time_zone(timezone)
  end

  def calc_total_time_in_care
    self.total_time_in_care = if check_in && check_out
                                check_out - check_in
                              elsif state == 'NE'
                                calculate_from_schedule
                              else
                                0.seconds
                              end
  end

  def calc_earned_revenue
    return unless state == 'NE'

    self.earned_revenue = child_approval.special_needs_rate ? ne_special_needs_revenue : ne_base_revenue
  end

  def ne_hours
    # TODO: this is super sloppy because this shouldn't be a service class but we haven't refactored these to procedures yet
    NebraskaHoursCalculator.new(child, check_in).round_hourly_to_quarters(total_time_in_care.seconds)
  end

  def ne_days
    # TODO: this is super sloppy because this shouldn't be a service class but we haven't refactored these to procedures yet
    NebraskaFullDaysCalculator.new(child, check_in).calculate_full_days_based_on_duration(total_time_in_care.seconds)
  end

  # TODO: open question - does qris bump impact this rate?
  def ne_special_needs_revenue
    (ne_hours * child_approval.special_needs_hourly_rate) + (ne_days * child_approval.special_needs_daily_rate)
  end

  def ne_base_revenue
    (ne_hours * ne_hourly_rate * business.ne_qris_bump) + (ne_days * ne_daily_rate * business.ne_qris_bump)
  end

  def ne_hourly_rate
    # TODO: License Types - possibly post-new-data-model
    ne_rates.hourly.first&.amount || 0
  end

  def ne_daily_rate
    # TODO: License Types - possibly post-new-data-model
    ne_rates.daily.first&.amount || 0
  end

  def ne_rates
    NebraskaRate
      .active_on_date(check_in)
      .where(school_age: child_approval.enrolled_in_school || false)
      .where('max_age >= ? OR max_age IS NULL', child.age_in_months(check_in))
      .where(region: ne_region)
      .where(accredited_rate: business.accredited)
      .order_max_age
  end

  def ne_region
    %w[Lancaster Dakota Douglas Sarpy].include?(business.county) ? 'LDDS' : 'Other'
  end

  def prevent_creation_of_absence_without_schedule
    return unless absence

    errors.add(:absence, "can't create for a day without a schedule") unless schedule_for_weekday
  end

  def calculate_from_schedule
    return 8.hours unless schedule_for_weekday

    Tod::Shift.new(schedule_for_weekday.start_time, schedule_for_weekday.end_time).duration
  end

  def schedule_for_weekday
    child_approval.child.schedules.active_on_date(check_in.to_date).for_weekday(check_in.wday).first
  end

  def check_out_after_check_in
    return if check_out.blank? || check_in.blank?

    errors.add(:check_out, 'must be after the check in time') if check_out < check_in
  end
end
# rubocop:enable Metrics/ClassLength

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  absence                                                        :string
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime
#  earned_revenue                                                 :decimal(, )
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#  wonderschool_id                                                :string
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
