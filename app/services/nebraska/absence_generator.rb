# frozen_string_literal: true

module Nebraska
  # Service to generate absences, to be scheduled daily
  class AbsenceGenerator
    attr_reader :child, :date

    def initialize(child, date = nil)
      @child = child
      @date = (date || Time.current).in_time_zone(child.timezone)
    end

    def call
      generate_absences
    end

    private

    def generate_absences
      return if attendance_on_date.present? || schedule.blank?

      ActiveRecord::Base.transaction do
        ServiceDay.find_or_create_by!(
          child: child,
          date: date,
          absence_type: 'absence',
          schedule: schedule
        )
      end
    end

    def schedule
      child.schedules.for_weekday(date.wday).active_on(date).first
    end

    def attendance_on_date
      child.attendances.where(check_in: date.at_beginning_of_day..date.at_end_of_day)
    end
  end
end
