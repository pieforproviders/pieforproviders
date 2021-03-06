# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    child_approval

    check_in do
      Faker::Time.between(from: Time.current.at_beginning_of_month, to: Time.current)
    end
    check_out { check_in + rand(0..23).hours + rand(0..59).minutes }

    absence { Random.rand(10) > 7 ? nil : Attendance::ABSENCE_TYPES.sample }

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
#  id                                                             :uuid             not null, primary key
#  absence                                                        :string
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#  wonderschool_id                                                :string
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
