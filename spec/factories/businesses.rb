# frozen_string_literal: true

FactoryBot.define do
  factory :business do
    sequence :name do |n|
      "#{Faker::Name.child_care_businesses}#{n}"
    end
    license_type { 'family_child_care_home_i' }
    user factory: :confirmed_user
    zipcode { '60606' }
    county { 'Cook' }

    factory :business_with_children do
      after :create do |business|
        create_list(:child, 3, business: business)
      end
    end

    trait :nebraska do
      zipcode { '68123' }
      county { 'Douglas' }
    end

    trait :accredited do
      accredited { true }
    end

    trait :unaccredited do
      accredited { false }
    end

    trait :not_rated do
      qris_rating { 'not_rated' }
    end

    trait :step_one do
      qris_rating { 'step_one' }
    end

    trait :step_two do
      qris_rating { 'step_two' }
    end

    trait :step_three do
      qris_rating { 'step_three' }
    end

    trait :step_four do
      qris_rating { 'step_four' }
    end

    trait :step_five do
      qris_rating { 'step_five' }
    end

    trait :gold do
      qris_rating { 'gold' }
    end

    trait :silver do
      qris_rating { 'silver' }
    end

    trait :bronze do
      qris_rating { 'bronze' }
    end
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  accredited   :boolean
#  active       :boolean          default(TRUE), not null
#  county       :string
#  deleted_at   :date
#  license_type :string           not null
#  name         :string           not null
#  qris_rating  :string
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
