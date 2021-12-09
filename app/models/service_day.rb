# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class ServiceDay < UuidApplicationRecord
  belongs_to :child
  has_many :attendances, dependent: :destroy
  has_many :child_approvals, -> { order(total_time_in_care: :desc).distinct }, through: :attendances

  validates :date, date_time_param: true, presence: true

  delegate :business, to: :child
  delegate :state, to: :child

  scope :absences, -> { joins(:attendances).where.not(attendances: { absence: nil }) }
  scope :non_absences, -> { joins(:attendances).where(attendances: { absence: nil }) }
  scope :covid_absences, -> { joins(:attendances).where(attendances: { absence: 'covid_absence' }) }
  scope :standard_absences, -> { joins(:attendances).where(attendances: { absence: 'absence' }) }
  scope :ne_hourly,
        lambda {
          joins(:attendances, { child: :business })
            .where(children: { businesses: { state: 'NE' } })
            .having(
              'sum("attendances"."total_time_in_care") <= ?',
              (5.hours + 45.minutes).to_s
            )
            .group(:id)
        }
  scope :ne_daily,
        lambda {
          joins(:attendances, { child: :business })
            .where(children: { businesses: { state: 'NE' } })
            .having(
              'sum("attendances"."total_time_in_care") between ? and ?',
              (5.hours + 46.minutes).to_s,
              10.hours.to_s
            )
            .group(:id)
        }
  scope :ne_daily_plus_hourly,
        lambda {
          joins(:attendances, { child: :business })
            .where(children: { businesses: { state: 'NE' } })
            .having(
              'sum("attendances"."total_time_in_care") between ? and ?',
              (10.hours + 1.minute).to_s,
              18.hours.to_s
            )
            .group(:id)
        }
  scope :ne_daily_plus_hourly_max,
        lambda {
          joins(:attendances, { child: :business })
            .where(children: { businesses: { state: 'NE' } })
            .having(
              'sum("attendances"."total_time_in_care") > ?',
              18.hours.to_s
            )
            .group(:id)
        }

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

  def absence?
    attendances.any? { |attendance| attendance.absence.present? }
  end

  def tags
    [tag_hourly, tag_daily, tag_absence].compact
  end

  def tag_hourly
    return unless state == 'NE'

    hourly? || daily_plus_hourly? || daily_plus_hourly_max? ? 'hourly' : nil
  end

  def tag_daily
    return unless state == 'NE'

    daily? || daily_plus_hourly? || daily_plus_hourly_max? ? 'daily' : nil
  end

  def tag_absence
    return unless state == 'NE'

    absence? ? 'absence' : nil
  end

  def hourly?
    return false unless state == 'NE'

    total_time_in_care <= (5.hours + 45.minutes)
  end

  def daily?
    return false unless state == 'NE'

    total_time_in_care > (5.hours + 45.minutes) && total_time_in_care <= 10.hours
  end

  def daily_plus_hourly?
    return false unless state == 'NE'

    total_time_in_care > 10.hours && total_time_in_care <= 18.hours
  end

  def daily_plus_hourly_max?
    return false unless state == 'NE'

    total_time_in_care > 18.hours
  end

  def earned_revenue
    return 0 unless state == 'NE'

    Nebraska::Daily::RevenueCalculator.new(
      business: business,
      child: child,
      child_approval: child.active_child_approval(date),
      date: date,
      total_time_in_care: total_time_in_care
    ).call
  end

  def total_time_in_care
      return calculate_nebraska_total_time if state == 'NE'
      attendances.sum(&:total_time_in_care)
  end

  def calculate_nebraska_total_time
    total_time = attendances.sum(&:total_time_in_care)
    duration = schedule_for_weekday&.duration || 8.hours
    return duration if total_time < duration && missing_clock_out?
    total_time
  end

  def missing_clock_out?
    attendances.each { |a| return true if a.check_in && !a.check_out }
    false
  end

  def schedule_for_weekday
    child.schedules.active_on_date(date).for_weekday(date.wday).first
  end
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
