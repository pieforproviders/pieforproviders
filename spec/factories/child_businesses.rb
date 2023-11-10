# frozen_string_literal: true

# factories/child_businesses.rb

FactoryBot.define do
  factory :child_business do
    business
    child

    currently_active { true }
  end
end

# == Schema Information
#
# Table name: child_businesses
#
#  id               :uuid             not null, primary key
#  currently_active :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_id      :uuid             not null
#  child_id         :uuid             not null
#
# Indexes
#
#  index_child_businesses_on_business_id  (business_id)
#  index_child_businesses_on_child_id     (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#  fk_rails_...  (child_id => children.id)
#
