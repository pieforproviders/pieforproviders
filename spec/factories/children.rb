# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    ccms_id { Faker::Number.number(digits: 10) }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65).strftime('%Y-%m-%d') }
    first_name { Faker::Name.first_name }
    full_name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    user
  end
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  first_name    :string           not null
#  full_name     :string           not null
#  last_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ccms_id       :string
#  user_id       :uuid             not null
#
# Indexes
#
#  index_children_on_user_id  (user_id)
#
