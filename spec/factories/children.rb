# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    date_of_birth { Faker::Date.birthday(min_age: 0, max_age: 18).strftime('%Y-%m-%d') }
    full_name { Faker::Name.name }
    business
    approvals { create_list(:approval, rand(1..3), create_children: false) }

    factory :child_in_illinois do
      after(:create) do |child|
        create(:illinois_approval_amount,
               child_approval: child.current_child_approval,
               month: Date.parse('March 2020'),
               part_days_approved_per_week: 3,
               full_days_approved_per_week: 2)
      end
    end
    trait :with_three_attendances do
      after(:create) do |child|
        # part day
        part_day_start = DateTime.parse('March 10, 2020 2:04 pm CST')
        create(:attendance, child_approval: child.current_child_approval, check_in: part_day_start, check_out: part_day_start + 4.hours + 10.minutes)

        # full day
        full_day_start = DateTime.parse('March 4, 2020 8:32 am CST')
        create(:attendance, child_approval: child.current_child_approval, check_in: full_day_start, check_out: full_day_start + 8.hours + 31.minutes)

        # full plus part day
        full_plus_part_day_start = DateTime.parse('March 12, 2020 9:18 am CST')
        create(:attendance, child_approval: child.current_child_approval, check_in: full_plus_part_day_start, check_out: full_plus_part_day_start + 14.hours + 29.minutes)
      end
    end
    trait :with_two_attendances do
      after(:create) do |child|
        # part day
        part_day_start = DateTime.parse('March 1, 2020 2:04 pm CST')
        create(:attendance, child_approval: child.current_child_approval, check_in: part_day_start, check_out: part_day_start + 4.hours + 10.minutes)

        # full day
        full_day_start = DateTime.parse('March 2, 2020 8:32 am CST')
        create(:attendance, child_approval: child.current_child_approval, check_in: full_day_start, check_out: full_day_start + 8.hours + 31.minutes)
      end
    end
  end
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  business_id   :uuid             not null
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
