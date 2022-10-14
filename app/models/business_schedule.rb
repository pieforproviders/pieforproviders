# frozen_string_literal: true

class BusinessSchedule < ApplicationRecord
  belongs_to :business

  validates :weekday, numericality: true, presence: true
  validates :is_open, inclusion: { in: [true, false] }
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
