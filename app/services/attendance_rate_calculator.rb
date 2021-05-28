# frozen_string_literal: true

# Service to calculate a family's attendance rate
class AttendanceRateCalculator < ApplicationService
  def initialize(child, filter_date)
    @child = child
    @filter_date = filter_date
    @state = child.business.state
  end

  def call
    calculate_attendance_rate
  end

  private

  def calculate_attendance_rate
    IllinoisAttendanceRateCalculator.new(@child, @filter_date).call if @state == 'IL'
  end
end
