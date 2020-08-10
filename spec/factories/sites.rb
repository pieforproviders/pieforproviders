# frozen_string_literal: true

FactoryBot.define do
  factory :site do
    name { Faker::Name.child_care_sites }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    county { Faker::Address.city_prefix }
    qris_rating { (1..5).to_a.push(nil).sample }
    business
  end
end

# == Schema Information
#
# Table name: sites
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  address     :string           not null
#  city        :string           not null
#  county      :string           not null
#  name        :string           not null
#  qris_rating :string
#  slug        :string           not null
#  state       :string           not null
#  zip         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_sites_on_name_and_business_id  (name,business_id) UNIQUE
#
