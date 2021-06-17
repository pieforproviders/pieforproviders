# frozen_string_literal: true

# Service to calculate full days used in Nebraska by specific kids
class NebraskaFullDaysCalculator
  def initialize(child, filter_date)
    @child = child
    @filter_date = filter_date
  end

  def call
    calculate_full_days
  end

  private

  def calculate_full_days
    @child.attendances.for_month(@filter_date).reduce(0) do |sum, attendance|
      sum + calculate_full_days_based_on_duration(attendance.total_time_in_care)
    end
  end

  def calculate_full_days_based_on_duration(duration)
    if duration > (5.hours + 45.minutes)
      1
    else
      0
    end
  end
end
