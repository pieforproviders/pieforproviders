# frozen_string_literal: true

# Service to calculate a service day's total time in care
# based on its attendances' accumulated time in care
class TotalTimeInCareCalculator
  attr_reader :attendances, :service_day

  def initialize(service_day:)
    @service_day = service_day
    @attendances = service_day.attendances
  end

  def call
    calculate_total_time
  end

  private

  def calculate_total_time
    Nebraska::TotalTimeInCareCalculator.new(service_day: service_day).call if service_day.child.state == 'NE'
    Illinois::TotalTimeInCareCalculator.new(service_day: service_day).call if service_day.child.state == 'IL'
  end

  def total_recorded_attended_time
    attendances_with_check_out = attendances.presence&.select do |attendance|
      attendance.check_out.present?
    end
    attendances_with_check_out.presence&.map(&:time_in_care)&.sum || 0.minutes
  end
end
