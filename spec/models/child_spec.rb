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

  context 'associates the record with a subsidy rule' do
    let!(:subsidy_rule_cook) { create(:subsidy_rule_for_illinois) }
    let!(:zipcode_cook) { create(:zipcode, county: subsidy_rule_cook.county, state: subsidy_rule_cook.state) }
    let!(:business_cook) { create(:business, county: zipcode_cook.county, zipcode: zipcode_cook) }
    let!(:child_cook) { create(:child, date_of_birth: Date.current - Random.rand(1..subsidy_rule_cook.max_age.to_i - 1).years, business: business_cook) }

    let!(:subsidy_rule_dupage) { create(:subsidy_rule_for_illinois, county: create(:county, state: State.find_by(abbr: 'IL'), name: 'DuPage')) }
    let!(:zipcode_dupage) { create(:zipcode, county: subsidy_rule_dupage.county, state: subsidy_rule_dupage.state) }
    let!(:business_dupage) { create(:business, county: zipcode_dupage.county, zipcode: zipcode_dupage) }

    it 'on creation' do
      expect(child_cook.current_subsidy_rule).to eq(subsidy_rule_cook)
    end

    it 'on update' do
      too_old_for_cook = Date.current - (subsidy_rule_cook.max_age.to_i + 1).years
      child_cook.update!(date_of_birth: too_old_for_cook)
      expect(child_cook.current_subsidy_rule).to be_nil
      child_cook.update!(date_of_birth: too_old_for_cook + 2.years)
      age_eligible_for_dupage = Date.current - Random.rand(1..subsidy_rule_dupage.max_age.to_i - 1).years
      expect(child_cook.current_subsidy_rule).to eq(subsidy_rule_cook)
      child_cook.update!(business: business_dupage)
      expect(child_cook.current_subsidy_rule).to eq(subsidy_rule_dupage)
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
