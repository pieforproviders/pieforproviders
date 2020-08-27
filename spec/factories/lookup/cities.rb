# frozen_string_literal: true

FactoryBot.define do
  factory :city, class: Lookup::City do
    name { Faker::Address.city }
    state
  end
end
