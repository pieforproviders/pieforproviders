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
      day_duration = calculate_full_time_and_part_time
      service_day.update!(full_time: day_duration[:full_time], part_time: day_duration[:part_time])
    end

    def missing_clock_out?
      attendances.any? do |attendance|
        attendance.check_in && !attendance.check_out
      end
    end

    def calculate_full_time_and_part_time
      if missing_clock_out?
        calculate_full_time_and_part_time_for_missing_checkout
      else
        Illinois::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    def calculate_full_time_and_part_time_for_missing_checkout
      response = {}
      # TODO: What happens if illinois_approval_amounts is not present?
      illinois_approvals = service_day.child.illinois_approval_amounts.for_month(service_day.date)
      return { full_time: 0, part_time: 0 } if illinois_approvals.none?

      part_days = illinois_approvals.map(&:part_days_approved_per_week).reduce(:+)
      full_days = illinois_approvals.map(&:full_days_approved_per_week).reduce(:+)
      response[:full_time] = full_days >= part_days ? 1 : 0
      response[:part_time] = full_days < part_days ? 1 : 0
      response
    end
  end
end
