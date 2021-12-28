# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
# rubocop:disable Metrics/ClassLength
class ServiceDay < UuidApplicationRecord
  belongs_to :child
  has_many :attendances, dependent: :destroy
  has_many :child_approvals, -> { order(total_time_in_care: :desc).distinct }, through: :attendances
  # has_many :approvals, through: :child_approvals, dependent: :restrict_with_error

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
              'sum("attendances"."time_in_care") <= ?',
              (5.hours + 45.minutes).to_s
            )
            .group(:id)
        }
  scope :ne_daily,
        lambda {
          joins(:attendances, { child: :business })
            .where(children: { businesses: { state: 'NE' } })
            .having(
              'sum("attendances"."time_in_care") between ? and ?',
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
              'sum("attendances"."time_in_care") between ? and ?',
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
              'sum("attendances"."time_in_care") > ?',
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

  def total_time_in_care(schedule_duration: nil)
    if state == 'NE'
      calculate_nebraska_total_time(schedule_duration: schedule_duration)
    else
      total_recorded_attended_time
    end
  end

  private

  def calculate_nebraska_total_time(schedule_duration: nil)
    scheduled_duration = calculate_scheduled_duration(schedule_duration: schedule_duration)

    if total_recorded_attended_time <= scheduled_duration && missing_clock_out?
      scheduled_duration
    else
      total_recorded_attended_time
    end
  end

  def total_recorded_attended_time
    attendances_with_check_out = attendances.presence&.select do |attendance|
      attendance.check_out.present?
    end
    attendances_with_check_out.presence&.map { |attendance| attendance.time_in_care }&.sum || 0.minutes
  end

  def calculate_scheduled_duration(schedule_duration:)
    schedule_duration || schedule_for_weekday&.duration || 8.hours
  end

  def missing_clock_out?
    attended_days = attendances.select { |attendance| attendance.absence.nil? }
    attended_days.empty? || attended_days.any? do |attendance|
      attendance.check_in && !attendance.check_out
    end
  end

  def schedule_for_weekday
    child.schedules.active_on(date).for_weekday(date.wday).first
  end
end
# rubocop:enable Metrics/ClassLength

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
#  index_service_days_on_date      (date)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
