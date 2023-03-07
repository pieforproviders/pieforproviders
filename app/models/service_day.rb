# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class ServiceDay < UuidApplicationRecord
  self.skip_time_zone_conversion_for_attributes = [:date]
  # if a schedule is deleted this field will be nullified, which doesn't trigger the callback in Schedule
  # to recalculate all service days total_time_in_care; this handles that use case
  after_save_commit :calculate_service_day
  before_save :set_absence_type_by_schedule

  belongs_to :child
  belongs_to :schedule, optional: true
  has_many :attendances, dependent: :destroy
  has_many :child_approvals, -> { distinct }, through: :attendances

  attribute :total_time_in_care, :interval

  monetize :earned_revenue_cents, allow_nil: true

  ABSENCE_TYPES = %w[
    absence_on_scheduled_day
    absence_on_unscheduled_day
    absence
    covid_absence
  ].freeze

  validates :absence_type, inclusion: { in: ABSENCE_TYPES }, allow_nil: true
  validates :date, date_time_param: true, presence: true
  validates :child, uniqueness: { scope: :date }

  delegate :business, to: :child
  delegate :state, to: :child

  scope :absences, -> { where.not(absence_type: nil) }
  scope :non_absences, -> { where(absence_type: nil) }
  scope :covid_absences, -> { where(absence_type: 'covid_absence') }
  scope :standard_absences, -> { where(absence_type: %w[absence absence_on_scheduled_day]) }
  scope :absence_on_scheduled_day, -> { where(absence_type: 'absence_on_scheduled_day') }
  scope :absence_on_unscheduled_day, -> { where(absence_type: 'absence_on_unscheduled_day') }

  scope :for_month,
        lambda { |month = nil|
          month ||= Time.current
          where('date BETWEEN ? AND ?', month.utc.at_beginning_of_month, month.utc.at_end_of_month)
        }
  scope :for_week,
        lambda { |week = nil|
          week ||= Time.current
          where('date BETWEEN ? AND ?', week.utc.at_beginning_of_week(:sunday), week.utc.at_end_of_week(:sunday))
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

  scope :for_period,
        lambda { |start_time = nil, end_time = nil|
          start_time ||= Time.current
          end_time ||= Time.current
          where(date: start_time.at_beginning_of_day..end_time.at_end_of_day)
        }

  scope :with_attendances, -> { includes(:attendances) }

  scope :full_day, -> { where('full_time > ?', 0) }
  scope :part_day, -> { where('part_time > ?', 0) }

  def absence?
    absence_type.present?
  end

  def schedule_for_weekday
    child.schedules.active_on(date).for_weekday(date.wday).first
  end

  def tags
    TagsCalculator.new(service_day: self).call
  end

  def calculate_service_day
    return unless previously_new_record? ||
                  saved_change_to_schedule_id?(to: nil) ||
                  saved_change_to_absence_type

    ServiceDayCalculatorJob.perform_later(self)
  end

  def set_absence_type_by_schedule
    return unless absence_type == 'absence'

    schedule = child.schedules.active_on(date).for_weekday(date.wday)
    self.absence_type = schedule.presence ? 'absence_on_scheduled_day' : 'absence_on_unscheduled_day'
  end
end
# == Schema Information
#
# Table name: service_days
#
#  id                      :uuid             not null, primary key
#  absence_type            :string
#  date                    :datetime         not null
#  earned_revenue_cents    :integer
#  earned_revenue_currency :string           default("USD"), not null
#  full_time               :integer          default(0)
#  missing_checkout        :boolean
#  part_time               :integer          default(0)
#  total_time_in_care      :interval
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  child_id                :uuid             not null
#  schedule_id             :uuid
#
# Indexes
#
#  index_service_days_on_child_id           (child_id)
#  index_service_days_on_child_id_and_date  (child_id,date) UNIQUE
#  index_service_days_on_date               (date)
#  index_service_days_on_full_time          (full_time)
#  index_service_days_on_part_time          (part_time)
#  index_service_days_on_schedule_id        (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
