# frozen_string_literal: true

# Service to calculate a family's attendance rate
class AttendanceRateCalculator
  def initialize(child, from_date)
    @child = child
    @from_date = from_date
    @state = child.business.state
  end

  def call
    calculate_attendance_rate
  end

  private

  def calculate_attendance_rate
    IllinoisAttendanceRateCalculator.new(@child, @from_date).call if @state == 'IL'
  end
end
