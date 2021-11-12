# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class ServiceDay < UuidApplicationRecord
  belongs_to :child
  has_many :attendances, dependent: :destroy

  validates :date, date_time_param: true, presence: true

  delegate :business, to: :child
  delegate :state, to: :child

  scope :absences, -> { includes(:attendances).where.not(attendances: { absence: nil }) }
  scope :non_absences, -> { includes(:attendances).where(attendances: { absence: nil }) }
  scope :hourly, -> { where(id: all.select(&:hourly?).map(&:id)) }
  scope :daily, -> { where(id: all.select(&:daily?).map(&:id)) }
  scope :daily_plus_hourly, -> { where(id: all.select(&:daily_plus_hourly?).map(&:id)) }
  scope :daily_plus_hourly_max, -> { where(id: all.select(&:daily_plus_hourly_max?).map(&:id)) }

  scope :for_month,
        lambda { |month = nil|
          month ||= Time.current
          where('date BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month)
        }
  scope :for_week,
        lambda { |week = nil|
          week ||= Time.current
          where('date BETWEEN ? AND ?', week.at_beginning_of_week(:sunday), week.at_end_of_week(:saturday))
        }

  scope :for_day,
        lambda { |day = nil|
          day ||= Time.current
          where('date BETWEEN ? AND ?', day.at_beginning_of_day, day.at_end_of_day)
        }

  def hourly?
    return unless state == 'NE'

    total_time_in_care <= (5.hours + 45.minutes)
  end

  def daily?
    return unless state == 'NE'

    total_time_in_care > (5.hours + 45.minutes) && total_time_in_care <= 10.hours
  end

  def daily_plus_hourly?
    return unless state == 'NE'

    total_time_in_care > 10.hours && total_time_in_care <= 18.hours
  end

  def daily_plus_hourly_max?
    return unless state == 'NE'

    total_time_in_care > 18.hours
  end

  def earned_revenue
    return unless state == 'NE'

    active_child_approval.special_needs_rate ? ne_special_needs_revenue : ne_base_revenue
  end

  def active_child_approval
    child.active_child_approval(date)
  end

  def total_time_in_care
    attendances.sum(&:total_time_in_care)
  end

  def ne_hours
    Nebraska::HoursCalculator.new(
      child: child,
      date: date,
      scope: :for_month
    ).round_hourly_to_quarters(total_time_in_care.seconds)
  end

  def ne_days
    Nebraska::FullDaysCalculator.new(
      child: child,
      date: date,
      scope: :for_month
    ).calculate_full_days_based_on_duration(total_time_in_care.seconds)
  end

  def ne_special_needs_revenue
    (ne_hours * active_child_approval.special_needs_hourly_rate) +
      (ne_days * active_child_approval.special_needs_daily_rate)
  end

  def ne_base_revenue
    (ne_hours * ne_hourly_rate * business.ne_qris_bump) +
      (ne_days * ne_daily_rate * business.ne_qris_bump)
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
    active_child_rates
      .where(region: ne_region)
      .where(license_type: business.license_type)
      .where(accredited_rate: business.accredited)
      .order_max_age
  end

  def active_child_rates
    NebraskaRate
      .active_on_date(date)
      .where(school_age: active_child_approval.enrolled_in_school || false)
      .where('max_age >= ? OR max_age IS NULL', child.age_in_months(date))
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
end

# == Schema Information
#
# Table name: service_days
#
#  id         :uuid             not null, primary key
#  date       :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_service_days_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
