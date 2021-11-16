# frozen_string_literal: true

module Nebraska
  # Service to calculate hours used in Nebraska by specific kids
  class HoursCalculator
    attr_reader :child, :date, :scope

    def initialize(child:, date:, scope:)
      @child = child
      @date = date
      @scope = scope
    end

    def call
      calculate_hours
    end

    def round_hourly_to_quarters(duration)
      (adjusted_duration(duration).in_minutes / 15.0).ceil * 15 / 60.0
    end

    private

    def calculate_hours
      service_days.reduce(0) do |sum, service_day|
        sum + round_hourly_to_quarters(service_day.total_time_in_care)
      end
    end

    def service_days
      service_days = child.active_child_approval(date).service_days.non_absences
      return service_days unless scope

      service_days.send(scope, date)
    end

    def adjusted_duration(duration)
      if duration <= (5.hours + 45.minutes)
        duration
      elsif duration > 10.hours && duration <= 18.hours
        duration - 10.hours
      elsif duration > 18.hours
        8.hours
      else
        0.minutes
      end
    end
  end
end
