# frozen_string_literal: true

# Service to reassign service days and recalculate their time when
# A schedule is updated
class ServiceDayScheduleUpdater
  attr_reader :child, :schedule, :service_days

  def initialize(schedule:)
    @schedule = schedule
    @child = schedule.child
    @service_days = active_service_days
  end

  def call
    reassign_service_days
    service_days.each(&:reload)
    calculate_service_day
  end

  private

  def active_service_days
    active_service_days = child.service_days.for_weekday(schedule.weekday).where('date >= ?', schedule.effective_on)
    schedule.expires_on ? active_service_days.where('date < ?', schedule.expires_on) : active_service_days
  end

  def reassign_service_days
    service_days.each { |sd| sd.update!(schedule: schedule) }
  end

  def calculate_service_day
    service_days.each { |service_day| ServiceDayCalculator.new(service_day: service_day).call }
  end
end
