# frozen_string_literal: true

FactoryBot.define do
  factory :service_day do
    child
    date { Faker::Time.between(from: Time.current.at_beginning_of_month, to: Time.current).to_datetime }
  end
end

# == Schema Information
#
# Table name: service_days
#
#  id                 :uuid             not null, primary key
#  date               :datetime         not null
#  total_time_in_care :interval
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  child_id           :uuid             not null
#  schedule_id        :bigint
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
#
