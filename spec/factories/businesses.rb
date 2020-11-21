# frozen_string_literal: true

FactoryBot.define do
  factory :business do
    sequence :name do |n|
      "#{Faker::Name.child_care_businesses}#{n}"
    end
    license_type { Licenses.types.keys.sample }
    user factory: :confirmed_user
    zipcode
    county { zipcode.county }

    factory :business_with_children do
      after :create do |business|
        create_list(:child, 3, business: business)
      end
    end
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  active       :boolean          default(TRUE), not null
#  license_type :string           not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  county_id    :uuid             not null
#  user_id      :uuid             not null
#  zipcode_id   :uuid             not null
#
# Indexes
#
#  index_businesses_on_county_id         (county_id)
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_user_id           (user_id)
#  index_businesses_on_zipcode_id        (zipcode_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (zipcode_id => zipcodes.id)
#
