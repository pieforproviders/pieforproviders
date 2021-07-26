# frozen_string_literal: true

# Service to calculate full days used in Nebraska by specific kids
class NebraskaWeeklyHoursAttendedCalculator
  def initialize(child, filter_date)
    @child = child
    @filter_date = filter_date
  end

  def call
    calculate_weekly_hours_attended
  end

  private

  def calculate_weekly_hours_attended
    "#{weekly_hours.in_hours.round(1)} of #{@child.active_child_approval(@filter_date).authorized_weekly_hours}"
  end

  def weekly_hours
    @child.attendances.for_week(@filter_date).reduce(0) do |sum, attendance|
      sum + attendance.total_time_in_care
    end
  end
end
