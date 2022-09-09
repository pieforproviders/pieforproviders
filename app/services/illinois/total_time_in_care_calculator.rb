# frozen_string_literal: true

module Illinois
  # Service to calculate a service day's total time in care
  # based on its attendances' accumulated time in care and Nebraska Rules
  class TotalTimeInCareCalculator < TotalTimeInCareCalculator
    attr_reader :attendances, :service_day

    def call
      calculate_total_time
    end

    private

    def calculate_total_time
      service_day.update!(total_time_in_care: total_recorded_attended_time)
      service_day.update!(missing_checkout: missing_clock_out?)
    end

    def missing_clock_out?
      attendances.any? do |attendance|
        attendance.check_in && !attendance.check_out
      end
    end
  end
end
