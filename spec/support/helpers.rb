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
    latest_day = latest_service_day(child_approval:)
    (latest_day && (latest_day + 1.day)) ||
      date.in_time_zone(child_approval.child.timezone) ||
      Time.current.in_time_zone(child_approval.child.timezone).at_beginning_of_day
  end

  def self.latest_service_day(child_approval:)
    days = child_approval.child.service_days.presence
    return nil unless days

    days.order(date: :desc).first.date.in_time_zone(child_approval.child.timezone).at_beginning_of_day
  end

  # rubocop:disable Metrics/MethodLength
  def self.build_nebraska_absence_list(num:, child_approval:, type: 'absence', date: nil)
    child = child_approval.child
    num.times do
      child.service_days.reload
      day_for_next_attendance = next_attendance_day(child_approval:, date:)
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
        child:,
        date: day_for_next_attendance,
        schedule:,
        absence_type: type
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
end
