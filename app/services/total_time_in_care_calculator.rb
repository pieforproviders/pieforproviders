# frozen_string_literal: true

# Service to recalculate a service day's total time in care
# based on its attendances' accumulated time in care
class TotalTimeInCareCalculator
  attr_reader :attendances, :service_day

  def initialize(service_day:)
    @service_day = service_day
    @attendances = service_day.attendances
  end

  def call
    recalculate_total_time_in_care
  end

  private

  def recalculate_total_time_in_care
    Nebraska::TotalTimeInCareCalculator.new(service_day: service_day).call if service_day.child.state == 'NE'
  end

  def total_recorded_attended_time
    attendances_with_check_out = attendances.presence&.select do |attendance|
      attendance.check_out.present?
    end
    attendances_with_check_out.presence&.map { |attendance| attendance.time_in_care }&.sum || 0.minutes
  end
end
