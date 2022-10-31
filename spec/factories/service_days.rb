# frozen_string_literal: true

FactoryBot.define do
  factory :service_day do
    child
    date do
      Time.current.in_time_zone(child.timezone).at_beginning_of_day
    end
    schedule { child.schedules.find_by(weekday: date.to_date.wday) }

    trait :absence do
      absence_type { ServiceDay::ABSENCE_TYPES.sample }
    end

    trait :on_scheduled_day do
      date do
        Helpers.next_weekday(
          Time.current.in_time_zone(child.timezone).at_beginning_of_day,
          child.schedules.first.weekday
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: service_days
#
#  id                      :uuid             not null, primary key
#  absence_type            :string
#  date                    :datetime         not null
#  earned_revenue_cents    :integer
#  earned_revenue_currency :string           default("USD"), not null
#  full_time               :integer          default(0)
#  missing_checkout        :boolean
#  part_time               :integer          default(0)
#  total_time_in_care      :interval
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  child_id                :uuid             not null
#  schedule_id             :uuid
#
# Indexes
#
#  index_service_days_on_child_id           (child_id)
#  index_service_days_on_child_id_and_date  (child_id,date) UNIQUE
#  index_service_days_on_date               (date)
#  index_service_days_on_full_time          (full_time)
#  index_service_days_on_part_time          (part_time)
#  index_service_days_on_schedule_id        (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
