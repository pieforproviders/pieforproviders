# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    latest_opening_time = (6 * 60).minutes # 6:00 am
    site_opening_time = Time.zone.parse(Date.current.to_s) + Random.rand(latest_opening_time).minutes # opens between midnight and 6 a.m.
    latest_check_in = (8 * 60).minutes # 8 hours after opening time

    min_time_in_care = 60.minutes
    max_time_in_care = (18 * 60).minutes

    starts_on { Date.current }
    # TODO: may need to change attendance_duration later after it is calculated.
    #   See the Attendance class more info
    attendance_duration { Attendance.attendance_durations.values.sample }

    check_in { Faker::Time.between(from: site_opening_time, to: (site_opening_time + latest_check_in)) }
    check_out do
      Faker::Time.between(from: check_in,
                          to: (check_in + min_time_in_care + Random.rand(max_time_in_care).minutes))
    end
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  attendance_duration                                            :enum             default("full_day"), not null
#  check_in                                                       :time             not null
#  check_out                                                      :time             not null
#  starts_on                                                      :date             not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#
