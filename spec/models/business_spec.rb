# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:name) }

  it 'validates uniqueness of business name' do
    create(:business)
    should validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:business)).to be_valid
  end

  it 'does not allow deactivation of a business with active children' do
    business = create(:business_with_children)
    business.update(active: false)
    expect(business.errors.messages[:active]).to be_present
    business.children.each { |child| child.update(active: false) }
    business.update(active: false)
    expect(business.errors.messages[:active]).not_to be_present
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
