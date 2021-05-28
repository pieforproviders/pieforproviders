# frozen_string_literal: true

# Expected attendance schedules for children
# used to calculate hours attended compared to hours scheduled
class Schedule < ApplicationRecord
  belongs_to :child

  validates :effective_on, date_param: true, presence: true
  validates :end_time, time_param: true, presence: true
  validates :expires_on, date_param: true, unless: proc { |schedule| schedule.expires_on_before_type_cast.nil? }
  validates :start_time, time_param: true, presence: true
  validates :weekday, numericality: true, presence: true
end

# == Schema Information
#
# Table name: schedules
#
#  id           :uuid             not null, primary key
#  effective_on :date             not null
#  end_time     :datetime         not null
#  expires_on   :date
#  start_time   :datetime         not null
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
