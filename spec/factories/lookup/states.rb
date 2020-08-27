# frozen_string_literal: true

FactoryBot.define do
  factory :state, class: Lookup::State do
    name { Faker::Address.state }
    abbr do
      # Faker::Address doesn't have a method to return the abbreviation for a given state
      state_number = Faker::Address.fetch_all('address.state').find_index(name)
      Faker::Address.fetch_all('address.state_abbr')[state_number]
    end
  end
end
