# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    latest_opening_time = (6 * 60).minutes # 6:00 am
    site_opening_time = Time.zone.parse(Date.current.to_s) + Random.rand(latest_opening_time).minutes # opens between midnight and 6 a.m.
    latest_check_in = (8 * 60).minutes # 8 hours after opening time

    min_time_in_care = 60.minutes
    max_time_in_care = (18 * 60).minutes

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
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime         not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#
