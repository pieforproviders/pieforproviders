# frozen_string_literal: true

FactoryBot.define do
  password = Faker::Internet.password
  factory :user do
    active { Faker::Boolean.boolean }
    email { Faker::Internet.email }
    full_name { Faker::Games::WorldOfWarcraft.hero }
    greeting_name { Faker::Name.first_name }
    language { %w[English Spanish Russian].sample }
    opt_in_email { Faker::Boolean.boolean }
    opt_in_phone { Faker::Boolean.boolean }
    opt_in_text { Faker::Boolean.boolean }
    organization { Faker::Company.name }
    password { password }
    password_confirmation { password }
    phone { Faker::PhoneNumber.phone_number }
    service_agreement_accepted { Faker::Boolean.boolean }
    timezone { TimeZoneService.us_zones.sample }
  end
end
# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE), not null
#  email                      :string           not null
#  full_name                  :string           not null
#  greeting_name              :string
#  language                   :string           not null
#  mobile                     :string
#  opt_in_email               :boolean          default(TRUE), not null
#  opt_in_phone               :boolean          default(TRUE), not null
#  opt_in_text                :boolean          default(TRUE), not null
#  organization               :string           not null
#  phone                      :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  slug                       :string           not null
#  timezone                   :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#
