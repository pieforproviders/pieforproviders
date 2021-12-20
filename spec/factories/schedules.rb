# frozen_string_literal: true

FactoryBot.define do
  factory :schedule do
    child
    effective_on { (Time.current - 6.months).to_date }
    weekday { rand(0..6) }
    duration { Faker::Number.between(from: 3600, to: 86_400).seconds }

    trait :expires do
      expires_on { effective_on + 1.year }
    end
  end
end

# == Schema Information
#
# Table name: schedules
#
#  id           :uuid             not null, primary key
#  deleted_at   :date
#  duration     :interval
#  effective_on :date             not null
#  expires_on   :date
#  weekday      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  child_id     :uuid             not null
#
# Indexes
#
#  index_schedules_on_child_id      (child_id)
#  index_schedules_on_effective_on  (effective_on)
#  index_schedules_on_expires_on    (expires_on)
#  index_schedules_on_updated_at    (updated_at)
#  index_schedules_on_weekday       (weekday)
#  unique_child_schedules           (effective_on,child_id,weekday) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
