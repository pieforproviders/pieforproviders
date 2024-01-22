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
      day_duration = calculate_full_time_and_part_time
      service_day.update!(full_time: day_duration[:full_time], part_time: day_duration[:part_time])
    end

    def calculate_full_time_and_part_time
      state = State.find_by(name: 'Nebraska')
      time_engine = TimeConversionEngine.new(service_day:, state:)
      time_engine.call
    end

    def schedule_or_duration
      scheduled_duration = schedule&.duration || 8.hours

      return scheduled_duration if service_day.absence?

      if total_recorded_attended_time <= scheduled_duration && missing_clock_out?
        scheduled_duration
      else
        total_recorded_attended_time
      end
    end

    def missing_clock_out?
      attendances.empty? || attendances.any? do |attendance|
        attendance.check_in && !attendance.check_out
      end
    end
  end
end
