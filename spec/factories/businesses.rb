# frozen_string_literal: true

FactoryBot.define do
  factory :business do
    sequence :name do |n|
      "#{Faker::Name.child_care_businesses}#{n}"
    end
    license_type { Licenses.types.keys.sample }
    user factory: :confirmed_user
    zipcode { '12345' }
    county { 'Cook' }

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
#  county       :string
#  license_type :string           not null
#  name         :string           not null
#  state        :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
