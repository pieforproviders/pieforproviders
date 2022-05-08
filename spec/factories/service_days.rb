# frozen_string_literal: true

FactoryBot.define do
  factory :service_day do
    child
    date do
      last_monday = Time.current.in_time_zone(child.timezone).prev_occurring(:monday)
      Faker::Time.between(from: last_monday.at_beginning_of_day, to: last_monday.at_end_of_day).to_datetime
    end

    trait :absence do
      absence_type { ServiceDay::ABSENCE_TYPES.sample }
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
#  total_time_in_care      :interval
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  child_id                :uuid             not null
#  schedule_id             :uuid
#
# Indexes
#
#  index_service_days_on_child_id     (child_id)
#  index_service_days_on_date         (date)
#  index_service_days_on_schedule_id  (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
