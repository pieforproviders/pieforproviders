# frozen_string_literal: true

# Service to calculate a family's attendance rate
class AttendanceRateCalculator
  def initialize(child, filter_date, business = nil, eligible_days: nil, attended_days: nil)
    @child = child
    @filter_date = filter_date
    child_business = child&.child_businesses&.find_by(currently_active: true)
    active_business = child&.businesses&.find(child_business.business_id)
    @state = child.present? ? active_business.state : business.state
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
