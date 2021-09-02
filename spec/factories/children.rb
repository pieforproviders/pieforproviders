# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    date_of_birth { Time.current.strftime('%Y-%m-%d') }
    full_name { Faker::Name.name }
    business
    approvals { [create(:approval, create_children: false)] }
    enrolled_in_school { false }

    factory :child_in_illinois do
      after(:create) do |child|
        12.times do |index|
          create(:illinois_approval_amount,
                 child_approval: child.active_child_approval(Time.zone.today),
                 month: child.active_child_approval(Time.zone.today).approval.effective_on + index.months,
                 part_days_approved_per_week: 3,
                 full_days_approved_per_week: 2)
        end
      end
    end

    factory :necc_child do
      transient do
        effective_date { Time.zone.today - 6.months }
        create_dashboard_case { false }
      end

      business { create(:business, :nebraska) }
      wonderschool_id { SecureRandom.uuid }
      approvals { [create(:approval, effective_on: effective_date, create_children: false)] }

      after(:create) do |child, evaluator|
        create(:temporary_nebraska_dashboard_case, child: child) if evaluator.create_dashboard_case
        create(:nebraska_approval_amount,
               child_approval: child.active_child_approval(evaluator.effective_date),
               effective_on: evaluator.effective_date - 2.months,
               family_fee: 80.00)
        child.child_approvals.first.update!(authorized_weekly_hours: 20)
      end
    end

    trait :with_two_illinois_attendances do
      after(:create) do |child|
        create(:illinois_part_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
        create(:illinois_full_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
      end
    end

    trait :with_three_illinois_attendances do
      after(:create) do |child|
        create(:illinois_part_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
        create(:illinois_full_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
        create(:illinois_full_plus_part_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
      end
    end

    trait :with_two_nebraska_attendances do
      after(:create) do |child|
        create(:nebraska_hourly_attendance, child_approval: child.active_child_approval(Time.zone.today))
        create(:nebraska_full_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
      end
    end

    trait :with_three_nebraska_attendances do
      after(:create) do |child|
        create(:nebraska_hourly_attendance, child_approval: child.active_child_approval(Time.zone.today))
        create(:nebraska_full_day_attendance, child_approval: child.active_child_approval(Time.zone.today))
        create(:nebraska_full_day_plus_hourly_attendance, child_approval: child.active_child_approval(Time.zone.today))
      end
    end
  end
end

# == Schema Information
#
# Table name: children
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE), not null
#  date_of_birth      :date             not null
#  deleted            :boolean          default(FALSE), not null
#  enrolled_in_school :boolean
#  full_name          :string           not null
#  inactive_reason    :string
#  last_active_date   :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_id        :uuid             not null
#  dhs_id             :string
#  wonderschool_id    :string
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
