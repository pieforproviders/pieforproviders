# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    date_of_birth { Faker::Date.birthday(min_age: 0, max_age: 9) }
    full_name { Faker::Movies::HarryPotter.character }
    greeting_name { Faker::Name.first_name }
  end
end
# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE)
#  date_of_birth :date
#  full_name     :string
#  greeting_name :string
#
