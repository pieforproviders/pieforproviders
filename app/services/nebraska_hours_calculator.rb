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
      return sum unless attendance.check_out

      duration = (attendance.check_out - attendance.check_in) / 60
      sum + round_hourly_to_quarters(duration)
    end
  end

  def round_hourly_to_quarters(duration)
    adjusted_duration = if duration < 360
                          duration
                        elsif duration > 600 && duration < 886
                          duration - 600
                        else
                          0
                        end
    (adjusted_duration / 60 * 4).round / 4.0
  end
end
