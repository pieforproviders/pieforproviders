# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    id { SecureRandom.uuid }
    code { 'NE' }
    name { 'Nebraska' }
    subsidy_type { nil }
    created_at { Time.current.at_beginning_of_day }
    updated_at { created_at }
  end
end

# == Schema Information
#
# Table name: states
#
#  id           :uuid             not null, primary key
#  code         :string
#  name         :string
#  subsidy_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#