# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    ccms_id { Faker::Number.number(digits: 10) }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65).strftime('%Y-%m-%d') }
    full_name { Faker::Name.name }
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
#  full_name     :string           not null
#  slug          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ccms_id       :string
#  user_id       :uuid             not null
#
# Indexes
#
#  index_children_on_slug     (slug) UNIQUE
#  index_children_on_user_id  (user_id)
#  unique_children            (full_name,date_of_birth,user_id) UNIQUE
#
