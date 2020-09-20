# frozen_string_literal: true

FactoryBot.define do
  factory :business do
    name { Faker::Name.child_care_businesses }
    license_type { Licenses.types.keys.sample }
    user factory: :confirmed_user
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  active       :boolean          default(TRUE), not null
#  license_type :enum
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_user_id           (user_id)
#
