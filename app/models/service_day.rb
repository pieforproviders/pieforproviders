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
