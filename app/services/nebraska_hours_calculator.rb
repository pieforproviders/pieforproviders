# frozen_string_literal: true

# Service to calculate hours used in Nebraska by specific kids
class NebraskaHoursCalculator
  def initialize(child, filter_date)
    @child = child
    @filter_date = filter_date
  end

  def call
    calculate_hours
  end

  private

  def calculate_hours
    @child.attendances.for_month(@filter_date).reduce(0) do |sum, attendance|
      sum + round_hourly_to_quarters(attendance.total_time_in_care)
    end
  end

  def round_hourly_to_quarters(duration)
    adjusted_duration = if duration < (5.hours + 45.minutes)
                          duration
                        elsif duration > 10.hours && duration < (14.hours + 45.minutes)
                          duration - 10.hours
                        else
                          0.minutes
                        end
    (adjusted_duration.in_minutes / 60 * 4).round / 4.0
  end
end
