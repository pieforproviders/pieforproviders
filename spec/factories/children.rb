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
