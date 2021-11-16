# frozen_string_literal: true

module Nebraska
  # Service to calculate full days used in Nebraska by specific kids
  class FullDaysCalculator
    attr_reader :child, :date, :scope

    def initialize(child:, date:, scope:)
      @child = child
      @date = date
      @scope = scope
    end

    def call
      calculate_full_days
    end

    def calculate_full_days_based_on_duration(duration)
      if duration > (5.hours + 45.minutes)
        1
      else
        0
      end
    end

    private

    def calculate_full_days
      service_days.reduce(0) do |sum, service_day|
        sum + calculate_full_days_based_on_duration(service_day.total_time_in_care)
      end
    end

    def service_days
      service_days = child.active_child_approval(date).service_days.non_absences
      return service_days unless scope

      service_days.send(scope, date)
    end
  end
end
