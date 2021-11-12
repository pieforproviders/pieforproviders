# frozen_string_literal: true

module Nebraska
  # Service to calculate full days used in Nebraska by specific kids
  class WeeklyHoursAttendedCalculator
    attr_reader :child, :filter_date

    def initialize(child, filter_date)
      @child = child
      @filter_date = filter_date
    end

    def call
      calculate_weekly_hours_attended
    end

    private

    def calculate_weekly_hours_attended
      weekly_hours.seconds.in_hours.round(1)
    end

    def weekly_hours
      # since this is an actual count of attended *hours* regardless of the classification
      # of the service day, we're summing actual time in care rather than using only hourly attendances
      child.service_days.non_absences.for_week(filter_date).reduce(0) do |sum, service_day|
        sum + service_day.total_time_in_care
      end
    end
  end
end
