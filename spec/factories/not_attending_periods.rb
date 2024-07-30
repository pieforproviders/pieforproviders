# frozen_string_literal: true

# Not attending period factory

FactoryBot.define do
  factory :not_attending_period do
    start_date { Time.zone.now }
    end_date { 5.days.from_now }
    child
  end
end

# == Schema Information
#
# Table name: not_attending_periods
#
#  id         :uuid             not null, primary key
#  end_date   :date
#  start_date :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_not_attending_periods_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
