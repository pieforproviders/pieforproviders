# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  it { should belong_to(:business) }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:date_of_birth) }

  it 'factory should be valid (default; no args)' do
    expect(build(:child)).to be_valid
  end

  it 'validates uniqueness of full name' do
    create(:child)
    should validate_uniqueness_of(:full_name).scoped_to(:date_of_birth, :business_id)
  end

  describe 'age_in_years' do
    let(:dec_15_kid) { build(:child, date_of_birth: Date.new(2015, 12, 15)) }

    describe 'handles leap year' do
      it 'recent birthday <= Feb 29 < given_date' do
        given_date = Date.new(2020, 3, 1)
        feb28_kid = build(:child, date_of_birth: Date.new(2019, 2, 28))
        expect(feb28_kid.age_in_years(given_date)).to eq 1.0055
      end

      it 'birthday is on a leap day' do
        given_date = Date.new(2020, 3, 1)
        feb29_kid = build(:child, date_of_birth: Date.new(2016, 2, 29))
        expect(feb29_kid.age_in_years(given_date)).to eq 4.0027
      end
    end

    it 'recent birthday was in previous year' do
      given_date = Date.new(2020, 1, 15)
      expect(dec_15_kid.age_in_years(given_date)).to eq 5.0849
    end

    it 'recent birthday happend this year' do
      given_date = Date.new(2020, 1, 1)
      expect(dec_15_kid.age_in_years(given_date)).to eq 5.0466
    end

    it 'birthday happens on the given date' do
      given_date = dec_15_kid.date_of_birth.change(year: 2020)
      expect(dec_15_kid.age_in_years(given_date)).to eq 5.0
    end
  end
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  business_id   :uuid             not null
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
