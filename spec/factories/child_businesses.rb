# factories/child_businesses.rb

FactoryBot.define do
  factory :child_businesses do
    child

    transient do
      businesses_count { 3 }
    end

    after(:create) do |child_business, evaluator|
      create_list(:business, evaluator.businesses_count).each do |business|
        create(:child_business, child: child_business.child, business: business)
      end
    end
  end
end

# == Schema Information
#
# Table name: child_businesses
#
#  id          :uuid             not null, primary key
#  active      :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#  child_id    :uuid             not null
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
