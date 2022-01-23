# frozen_string_literal: true

module Nebraska
  # Service to calculate a service day's total time in care
  # based on its attendances' accumulated time in care and Nebraska Rules
  class TotalTimeInCareCalculator < TotalTimeInCareCalculator
    attr_reader :attendances, :schedule, :service_day

    def initialize(service_day:)
      super
      @schedule = service_day.schedule
    end

    def call
      calculate_total_time
    end

    private

    def calculate_total_time
      service_day.update!(total_time_in_care: schedule_or_duration)
    end

    def schedule_or_duration
      scheduled_duration = schedule&.duration || 8.hours

      if total_recorded_attended_time <= scheduled_duration && missing_clock_out?
        scheduled_duration
      else
        total_recorded_attended_time
      end
    end

    def missing_clock_out?
      attended_days = attendances.select { |attendance| attendance.absence.nil? }
      attended_days.empty? || attended_days.any? do |attendance|
        attendance.check_in && !attendance.check_out
      end
    end
  end
end
