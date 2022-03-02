# frozen_string_literal: true

require Rails.root.join('spec/support/helpers')

FactoryBot.define do
  factory :attendance do
    child_approval

    check_in do
      Faker::Time
        .between(from: Time.current.at_beginning_of_month, to: Time.current)
        .in_time_zone(child_approval.child.timezone)
        .at_beginning_of_day
    end
    check_out { check_in + rand(3..23).hours + rand(0..59).minutes }

    factory :nebraska do
      child_approval do
        child = create(:necc_child)
        child.child_approvals.first
      end
      check_in do
        child = child_approval.child
        child.reload
        date = child.schedules.first.effective_on.in_time_zone(child.timezone) + 30.days
        Helpers.next_weekday(date, child.schedules.first.weekday)
      end

      trait :recent do
        check_in do
          Faker::Time
            .between(from: Time.current.at_beginning_of_month, to: Time.current)
            .in_time_zone(child_approval.child.timezone)
            .at_beginning_of_day
        end
      end

      trait :absence do
        check_out { nil }
        absence { Attendance::ABSENCE_TYPES.sample }
      end

      trait :hourly do
        check_out { check_in + 5.hours + 20.minutes }
      end

      trait :daily do
        check_out { check_in + 7.hours + 19.minutes }
      end

      trait :daily_plus_hourly do
        check_out { check_in + 14.hours + 42.minutes }
      end

      trait :daily_plus_hourly_max do
        check_out { check_in + 19.hours + 11.minutes }
      end

      factory :nebraska_absence, traits: [:absence]
      factory :nebraska_hourly_attendance, traits: [:hourly]
      factory :nebraska_daily_attendance, traits: [:daily]
      factory :nebraska_daily_plus_hourly_attendance, traits: [:daily_plus_hourly]
      factory :nebraska_max_attendance, traits: [:daily_plus_hourly_max]
    end

    factory :illinois_part_day_attendance do
      check_in do
        Faker::Time.between(from: Time.current.at_beginning_of_month, to: Time.current)
      end
      check_out { check_in + 2.hours + 13.minutes }
    end

    factory :illinois_full_day_attendance do
      check_in do
        Faker::Time.between(from: Time.current.at_beginning_of_month, to: Time.current)
      end
      check_out { check_in + 8.hours + 21.minutes }
    end

    factory :illinois_full_plus_part_day_attendance do
      check_in do
        Faker::Time.between(from: Time.current.at_beginning_of_month, to: Time.current)
      end
      check_out { check_in + 14.hours + 48.minutes }
    end

    factory :illinois_full_plus_full_day_attendance do
      check_in do
        Faker::Time.between(from: Time.current.at_beginning_of_month, to: Time.current)
      end
      check_out { check_in + 18.hours + 11.minutes }
    end
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                       :uuid             not null, primary key
#  absence                                                  :string
#  check_in                                                 :datetime         not null
#  check_out                                                :datetime
#  deleted_at                                               :date
#  time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                               :datetime         not null
#  updated_at                                               :datetime         not null
#  child_approval_id                                        :uuid             not null
#  service_day_id                                           :uuid
#  wonderschool_id                                          :string
#
# Indexes
#
#  index_attendances_on_absence            (absence)
#  index_attendances_on_check_in           (check_in)
#  index_attendances_on_child_approval_id  (child_approval_id)
#  index_attendances_on_service_day_id     (service_day_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#  fk_rails_...  (service_day_id => service_days.id)
#
