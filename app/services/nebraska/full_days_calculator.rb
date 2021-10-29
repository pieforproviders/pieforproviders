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
      attendances.reduce(0) do |sum, attendance|
        sum + calculate_full_days_based_on_duration(attendance.total_time_in_care)
      end
    end

    def attendances
      attendances = child.active_child_approval(date).attendances.non_absences
      return attendances unless scope

      attendances.send(scope, date)
    end
  end
end
