# frozen_string_literal: true

FactoryBot.define do
  factory :schedule do
    child
    effective_on { (Time.current - 6.months).to_date }
    end_time { '4:00pm' }
    start_time { '11:00am' }
    weekday { rand(1..7) }

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
#  effective_on :date             not null
#  end_time     :time             not null
#  expires_on   :date
#  start_time   :time             not null
#  weekday      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  child_id     :uuid             not null
#
# Indexes
#
#  index_schedules_on_child_id  (child_id)
#  unique_child_schedules       (effective_on,child_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
