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
  scope :covid_absences, -> { includes(:attendances).where(attendances: { absence: 'covid_absence' }) }
  scope :standard_absences, -> { includes(:attendances).where(attendances: { absence: 'absence' }) }
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

  def absence?
    attendances.any? { |attendance| attendance.absence.present? }
  end

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

    Nebraska::Daily::RevenueCalculator.new(
      business: business,
      child: child,
      date: date,
      total_time_in_care: total_time_in_care
    ).call
  end

  def total_time_in_care
    attendances.sum(&:total_time_in_care)
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
