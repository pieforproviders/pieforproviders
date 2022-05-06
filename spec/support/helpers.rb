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
    service_days = child_approval.child.service_days
    service_days.reload
    if service_days.present?
      service_days
        .order(date: :desc)
        .first.date.in_time_zone(child_approval.child.timezone)
        .at_beginning_of_day + 1.day
    else
      date || Time.current.at_beginning_of_day
    end
  end

  def self.build_nebraska_absence_list(num:, child_approval:, type: 'absence', date: nil)
    child = child_approval.child
    num.times do
      child.service_days.reload
      day_for_next_attendance = next_attendance_day(child_approval: child_approval, date: date)
      while child.schedules.where(
        weekday: day_for_next_attendance.wday,
        effective_on: ..day_for_next_attendance,
        expires_on: [day_for_next_attendance.., nil]
      ).blank?
        day_for_next_attendance += 1.day
      end
      schedule = child.schedules.where(
        weekday: day_for_next_attendance.wday,
        effective_on: ..day_for_next_attendance,
        expires_on: [day_for_next_attendance.., nil]
      ).first
      FactoryBot.create(
        :service_day,
        child: child,
        date: day_for_next_attendance,
        schedule: schedule,
        absence_type: type
      )
    end
  end
end
