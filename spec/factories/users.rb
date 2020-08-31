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
    opt_in_text { Faker::Boolean.boolean }
    organization { Faker::Company.name }
    password { password }
    password_confirmation { password }
    phone_number { Faker::PhoneNumber.phone_number }
    phone_type { %w[cell home work].sample }
    service_agreement_accepted { true }
    timezone { TimeZoneService.us_zones.sample }

    factory :confirmed_user do
      before(:create, &:skip_confirmation!)
    end
  end
end
# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE), not null
#  confirmation_sent_at       :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :string           not null
#  encrypted_password         :string           default(""), not null
#  failed_attempts            :integer          default(0), not null
#  full_name                  :string           not null
#  greeting_name              :string
#  language                   :string           not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  locked_at                  :datetime
#  opt_in_email               :boolean          default(TRUE), not null
#  opt_in_text                :boolean          default(TRUE), not null
#  organization               :string           not null
#  phone_number               :string
#  phone_type                 :string
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  sign_in_count              :integer          default(0), not null
#  slug                       :string           not null
#  timezone                   :string           not null
#  unconfirmed_email          :string
#  unlock_token               :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_phone_number          (phone_number) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_slug                  (slug) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
