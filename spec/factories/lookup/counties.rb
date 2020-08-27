# frozen_string_literal: true

FactoryBot.define do
  factory :county, class: Lookup::County do
    name { Faker::Address.community }
    state
    zipcodes { [ build(:zipcode) ] }
  end
end
