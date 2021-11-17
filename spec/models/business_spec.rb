# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:qris_rating).in_array(Business::QRIS_RATINGS) }

  it_behaves_like 'licenses'

  it 'validates uniqueness of business name' do
    business = create(:business)
    expect(business).to validate_uniqueness_of(:name).scoped_to(:user_id)
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

  describe '#ne_qris_bump' do
    it 'uses the accredited bump if the business is accredited' do
      business = create(:business, :nebraska_ldds, :accredited, :step_five)
      expect(business.ne_qris_bump).to eq(1.05**2)
      business.update!(accredited: false)
      expect(business.ne_qris_bump).to eq(1.05**3)
    end

    it 'uses the correct qris_rating' do
      business = create(:business, :nebraska_ldds, :accredited, :step_five)
      expect(business.ne_qris_bump).to eq(1.05**2)
      business.update!(qris_rating: 'not_rated')
      expect(business.ne_qris_bump).to eq(1.05**0)
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
