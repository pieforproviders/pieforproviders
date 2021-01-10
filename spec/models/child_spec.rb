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
    let!(:date) { Date.current }
    let!(:subsidy_rule_cook_age5) { create(:subsidy_rule_for_illinois, max_age: 5) }
    let!(:subsidy_rule_cook_age3) { create(:subsidy_rule_for_illinois, max_age: 3) }
    let!(:business_cook) { create(:business, county: 'Cook', zipcode: '60606') }
    let!(:child_cook) { create(:child, date_of_birth: Date.current - 2.years, business: business_cook) }
    let!(:subsidy_rule_dupage) { create(:subsidy_rule_for_illinois, county: 'DuPage') }
    let!(:business_dupage) { create(:business, county: 'DuPage', zipcode: '60613') }

    it 'on creation' do
      expect(child_cook.active_subsidy_rule(date)).to eq(subsidy_rule_cook_age3)
    end

    it 'on update' do
      too_old_for_cook = child_cook.date_of_birth - 4.years
      child_cook.update!(date_of_birth: too_old_for_cook)
      expect(child_cook.active_subsidy_rule(date)).to be_nil
      child_cook.update!(date_of_birth: too_old_for_cook + 2.years)
      expect(child_cook.active_subsidy_rule(date)).to eq(subsidy_rule_cook_age5)
      age_eligible_for_dupage = Date.current - Random.rand(1..subsidy_rule_dupage.max_age.to_i - 1).years
      child_cook.update!(date_of_birth: age_eligible_for_dupage)
      child_cook.update!(business: business_dupage)
      expect(child_cook.active_subsidy_rule(date)).to eq(subsidy_rule_dupage)
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
