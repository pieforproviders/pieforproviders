# frozen_string_literal: true

FactoryBot.define do
  factory :business_schedule do
    weekday { rand(0..6) }
    is_open { true }
  end
end

# == Schema Information
#
# Table name: business_schedules
#
#  id          :uuid             not null, primary key
#  is_open     :boolean          not null
#  weekday     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_business_schedules_on_business_id  (business_id)
#  unique_business_schedules                (business_id,weekday) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
