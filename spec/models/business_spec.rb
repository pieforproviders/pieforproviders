# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:quality_rating).in_array(QualityRatings::TYPES) }
  it { is_expected.to have_many(:business_schedules) }
  it { is_expected.to accept_nested_attributes_for :business_schedules }

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

    it 'uses the correct quality_rating' do
      business = create(:business, :nebraska_ldds, :accredited, :step_five)
      expect(business.ne_qris_bump).to eq(1.05**2)
      business.update!(quality_rating: 'not_rated')
      expect(business.ne_qris_bump).to eq(1.05**0)
    end
  end

  describe '#set_default_schedules' do
    it 'does not create schedules if business is not from IL' do
      business = create(:business, state: 'NY', zipcode: '10007')
      expect(business.business_schedules.count).to eq(0)
    end

    it 'creates schedules for 7 days if business is from IL' do
      business = create(:business)
      expect(business.business_schedules.count).to eq(7)
    end

    it 'does not create schedules if business is from IL and already has an schedule' do
      attrs = attributes_for(:business_schedule)
      business = create(:business, business_schedules_attributes: [attrs])
      expect(business.business_schedules.count).to eq(1)
    end

    it 'creates open schedules from Monday to Friday for business in IL' do
      business = create(:business)
      weekdays = business.business_schedules.where(is_open: true)
      weekend_days = business.business_schedules.where(is_open: false)
      expect(weekdays.count).to eq(5)
      expect(weekdays.map(&:weekday)).to eq([1, 2, 3, 4, 5])
      expect(weekend_days.map(&:weekday)).to eq([0, 6])
    end
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id              :uuid             not null, primary key
#  accredited      :boolean
#  active          :boolean          default(TRUE), not null
#  county          :string
#  deleted_at      :date
#  inactive_reason :string
#  license_type    :string           not null
#  name            :string           not null
#  quality_rating  :string
#  state           :string
#  zipcode         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :uuid             not null
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
