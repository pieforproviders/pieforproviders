# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:quality_rating).in_array(QualityRatings::TYPES) }
  it { is_expected.to have_many(:business_schedules) }
  it { is_expected.to have_many(:business_closures) }
  it { is_expected.to accept_nested_attributes_for :business_schedules }
  it { is_expected.to accept_nested_attributes_for :business_closures }

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

  describe '#il_quality_bump' do
    it 'checks the Illinois quality bump for nil quality rating' do
      business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: nil)
      expect(business.il_quality_bump).to eq(1)
    end

    it 'checks the Illinois quality bump for bronze quality rating' do
      business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'bronze')
      expect(business.il_quality_bump).to eq(1)
    end

    it 'checks the Illinois quality bump for silver quality rating' do
      business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'silver')
      expect(business.il_quality_bump).to eq(1.1)
    end

    it 'checks the Illinois quality bump for gold quality rating' do
      business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'gold')
      expect(business.il_quality_bump).to eq(1.15)
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

  describe '#eligible_by_date' do
    let(:business) do
      create(:business, business_closures_attributes: [attributes_for(:business_closure)])
    end

    it 'is eligible if provider is closed on a given date' do
      any_date = Date.new(2022, 1, 10)
      expect(business.eligible_by_date?(any_date)).to be(true)
    end

    it 'is not eligible if provider is closed on a given date' do
      july_4th = Date.new(2022, 7, 4)
      expect(business.eligible_by_date?(july_4th)).to be(false)
    end

    it 'is not eligible if provider is closed on a Holiday' do
      december_25th = Date.new(2022, 12, 25)
      create(:holiday)
      expect(business.eligible_by_date?(december_25th)).to be(false)
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
