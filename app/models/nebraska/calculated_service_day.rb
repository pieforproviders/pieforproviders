# frozen_string_literal: true

module Nebraska
  # A service day with its earned revenue and duration calculated
  # for use in the dashboard endpoint
  class CalculatedServiceDay
    attr_reader :attendances,
                :child,
                :child_approval,
                :business,
                :date,
                :service_day,
                :schedule,
                :total_time_in_care,
                :weekday

    def initialize(service_day:)
      @service_day = service_day
      @attendances = service_day.attendances
      @child = service_day.child
      @date = service_day.date.to_date
      @weekday = date.wday
      @schedule = service_day.schedules.active_on(date).where(weekday: weekday).first
      @child_approval = child.active_child_approval(date)
      @business = child.business
      @total_time_in_care = total_time_in_care
    end

    def total_time_in_care
      attendances.presence&.sum(&:total_time_in_care) || schedule.duration || 0.minutes
    end

    def absence?
      attendances.absences.any?
    end

    def days
      Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: total_time_in_care).call
    end

    def hours
      Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: total_time_in_care).call
    end

    def earned_revenue
      Nebraska::Daily::RevenueCalculator.new(
        business: business,
        child: child,
        child_approval: child_approval,
        date: date,
        hours: hours,
        days: days
      ).call
    end
  end
end
