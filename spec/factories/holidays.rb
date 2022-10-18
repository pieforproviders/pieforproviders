# frozen_string_literal: true

FactoryBot.define do
  factory :holiday do
    date { Date.new(2022, 12, 25) }
  end
end

# == Schema Information
#
# Table name: holidays
#
#  id         :uuid             not null, primary key
#  date       :date
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  unique_holiday  (name,date) UNIQUE
#
