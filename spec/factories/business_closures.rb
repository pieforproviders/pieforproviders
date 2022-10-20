# frozen_string_literal: true

FactoryBot.define do
  factory :business_closure do
    date { '2022-07-04' }

    factory :business_with_closed_day_in_november do
      date { '2022-11-04' }
    end
  end
end

# == Schema Information
#
# Table name: business_closures
#
#  id          :uuid             not null, primary key
#  date        :date
#  is_holiday  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_business_closures_on_business_id  (business_id)
#  unique_business_closure                 (business_id,date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
