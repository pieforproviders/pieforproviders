# frozen_string_literal: true

# Service to calculate a family's attendance rate
class AttendanceRateCalculator
  def initialize(child, filter_date, business = nil, eligible_days: nil, attended_days: nil)
    @child = child
    @filter_date = filter_date
    @state = child.present? ? child.business.state : business.state
    @eligible_days = eligible_days
    @attended_days = attended_days
  end

  def call
    calculate_attendance_rate
  end

  private

  def calculate_attendance_rate
    return unless @state == 'IL'

    IllinoisAttendanceRateCalculator.new(
      @child,
      @filter_date,
      eligible_days: @eligible_days,
      attended_days: @attended_days
    ).call
  end
end
