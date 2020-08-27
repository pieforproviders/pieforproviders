# frozen_string_literal: true

FactoryBot.define do
  factory :zipcode, class: Lookup::Zipcode do
    code { Faker::Address.zip_code(state_abbreviation: state.abbr) }
    state
  end
end
