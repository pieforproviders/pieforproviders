# frozen_string_literal: true

# Expected attendance schedules for children
# used to calculate hours attended compared to hours scheduled
class Schedule < ApplicationRecord
  after_save_commit :update_service_day_schedules

  belongs_to :child
  has_many :service_days, dependent: :nullify

  attribute :duration, :interval

  validates :effective_on, date_param: true, presence: true
  validates :expires_on, date_param: true, unless: proc { |schedule| schedule.expires_on_before_type_cast.nil? }
  validates :weekday, numericality: true, presence: true
  validates :duration, presence: true

  scope :active_on,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc)
        }
  scope :for_month,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)',
                date.at_beginning_of_month,
                date.at_end_of_month).order(updated_at: :desc)
        }
  scope :for_weekday, ->(weekday) { where(weekday: weekday).order(updated_at: :desc) }

  private

  def update_service_day_schedules
    ServiceDayScheduleUpdater.new(schedule: self).call
  end
end

# == Schema Information
#
# Table name: schedules
#
#  id           :uuid             not null, primary key
#  deleted_at   :date
#  duration     :interval
#  effective_on :date             not null
#  expires_on   :date
#  weekday      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  child_id     :uuid             not null
#
# Indexes
#
#  index_schedules_on_child_id      (child_id)
#  index_schedules_on_effective_on  (effective_on)
#  index_schedules_on_expires_on    (expires_on)
#  index_schedules_on_updated_at    (updated_at)
#  index_schedules_on_weekday       (weekday)
#  unique_child_schedules           (effective_on,child_id,weekday) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
