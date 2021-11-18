# frozen_string_literal: true

require 'factory_bot_rails'

module Helpers
  def self.next_weekday(date, weekday)
    date.next_occurring(Date::DAYNAMES[weekday].downcase.to_sym)
  end

  def self.prior_weekday(date, weekday)
    date.prev_occurring(Date::DAYNAMES[weekday].downcase.to_sym)
  end

  def self.last_elapsed_date(date)
    if Date.parse(date).month > Time.current.month
      Date.parse("#{date}, #{Time.current.year - 1}")
    else
      Date.parse("#{date}, #{Time.current.year}")
    end
  end

  def self.next_attendance_day(child_approval:, date: nil)
    attendances = child_approval.attendances
    attendances.reload
    if attendances.present?
      attendances
        .order(check_in: :desc)
        .first.check_in.in_time_zone(child_approval.child.timezone)
        .at_beginning_of_day + 1.day
    else
      date || Time.current.at_beginning_of_day
    end
  end

  def self.build_nebraska_absence_list(num:, child_approval:, type: 'absence', date: nil)
    child = child_approval.child
    child.reload
    num.times do
      day_for_next_attendance = next_attendance_day(child_approval: child_approval, date: date)
      while child.schedules.select { |schedule| schedule.weekday == day_for_next_attendance.wday }.blank?
        day_for_next_attendance += 1.day
      end
      FactoryBot.create(
        :nebraska_absence,
        child_approval: child_approval,
        check_in: day_for_next_attendance + 3.hours,
        check_out: nil,
        absence: type
      )
    end
  end
end
