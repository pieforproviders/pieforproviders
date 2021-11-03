# frozen_string_literal: true

# Service to generate absences, to be scheduled daily
class NebraskaAbsenceGenerator
  def initialize(child, date = nil)
    @child = child
    @date = (date || Time.current).in_time_zone(@child.timezone)
  end

  def call
    generate_absences
  end

  private

  def generate_absences
    return if attendance_on_date.present? || schedule.empty? || child_approval.nil?

    ActiveRecord::Base.transaction do
      Attendance.find_or_create_by!(
        child_approval: child_approval,
        check_in: @date.at_beginning_of_day,
        check_out: nil,
        absence: 'absence'
      )
    end
  end

  def schedule
    @child.schedules.for_weekday(@date.wday)
  end

  def child_approval
    @child.active_child_approval(@date)
  end

  def attendance_on_date
    @child.attendances.where(check_in: @date.at_beginning_of_day..@date.at_end_of_day)
  end
end
