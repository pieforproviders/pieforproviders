# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    transient do
      effective_date { 9.months.ago }
    end
    date_of_birth { 2.years.ago.strftime('%Y-%m-%d') }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    business
    approvals { [create(:approval, create_children: false, effective_on: effective_date)] }

    factory :child_in_illinois do
      after(:create) do |child|
        12.times do |index|
          create(:illinois_approval_amount,
                 child_approval: child.active_child_approval(Time.current),
                 month: child.active_child_approval(Time.current).approval.effective_on + index.months,
                 part_days_approved_per_week: 3,
                 full_days_approved_per_week: 2)
        end
      end
    end

    factory :necc_child do
      transient do
        effective_date { 6.months.ago }
      end
      business { create(:business, :nebraska_ldds) }
      wonderschool_id { SecureRandom.uuid }
      approvals { [create(:approval, create_children: false, effective_on: effective_date)] }

      after(:create) do |child, evaluator|
        create(:nebraska_approval_amount,
               child_approval: child.child_approvals.first,
               effective_on: evaluator.effective_date,
               family_fee: 80.00)
        child.child_approvals.first.update!(authorized_weekly_hours: 20.0)
        child.schedules.reload
      end
    end

    trait :with_two_illinois_attendances do
      after(:create) do |child|
        service_day = create(:service_day, child: child)
        create(:illinois_part_day_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
        create(:illinois_full_day_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
      end
    end

    trait :with_three_illinois_attendances do
      after(:create) do |child|
        service_day = create(:service_day, child: child)
        create(:illinois_part_day_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
        create(:illinois_full_day_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
        create(:illinois_full_plus_part_day_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
      end
    end

    trait :with_two_nebraska_attendances do
      after(:create) do |child|
        service_day = create(:service_day, child: child)
        create(:nebraska_hourly_attendance,
               :recent,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
        create(:nebraska_daily_attendance,
               :recent,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
      end
    end

    trait :with_three_nebraska_attendances do
      after(:create) do |child|
        service_day = create(:service_day, child: child)
        create(:nebraska_hourly_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
        create(:nebraska_daily_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
        create(:nebraska_daily_plus_hourly_attendance,
               service_day: service_day,
               child_approval: child.active_child_approval(Time.current))
      end
    end
  end
end

# == Schema Information
#
# Table name: children
#
#  id               :uuid             not null, primary key
#  active           :boolean          default(TRUE), not null
#  date_of_birth    :date             not null
#  deleted_at       :date
#  first_name       :string           not null
#  inactive_reason  :string
#  last_active_date :date
#  last_name        :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_id      :uuid             not null
#  dhs_id           :string
#  wonderschool_id  :string
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  index_children_on_deleted_at   (deleted_at)
#  unique_children                (first_name,last_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
