# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class ServiceDay < UuidApplicationRecord
  # if a schedule is deleted this field will be nullified, which doesn't trigger the callback in Schedule
  # to recalculate all service days total_time_in_care; this handles that use case
  after_save_commit :calculate_service_day,
                    on: :update,
                    if: proc { |service_day|
                          service_day.saved_change_to_schedule_id?(to: nil)
                        }

  belongs_to :child
  belongs_to :schedule, optional: true
  has_many :attendances, dependent: :destroy
  has_many :child_approvals, -> { distinct }, through: :attendances

  attribute :total_time_in_care, :interval

  monetize :earned_revenue_cents, allow_nil: true

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

  scope :for_weekday,
        lambda { |weekday|
          where("select date_part('dow', DATE(date)) = ?", weekday)
        }

  scope :with_attendances, -> { includes(attendances: :child_approval) }

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

  def calculate_service_day
    ServiceDayCalculatorJob.perform_later(id)
  end
end
# == Schema Information
#
# Table name: service_days
#
#  id                      :uuid             not null, primary key
#  date                    :datetime         not null
#  earned_revenue_cents    :integer
#  earned_revenue_currency :string           default("USD"), not null
#  total_time_in_care      :interval
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  child_id                :uuid             not null
#  schedule_id             :uuid
#
# Indexes
#
#  index_service_days_on_child_id     (child_id)
#  index_service_days_on_date         (date)
#  index_service_days_on_schedule_id  (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
