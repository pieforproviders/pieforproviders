# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65).strftime('%Y-%m-%d') }
    full_name { Faker::Name.name }
    business
    approvals { create_list(:approval, rand(1..3), create_children: false) }
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
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  business_id   :uuid             not null
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
