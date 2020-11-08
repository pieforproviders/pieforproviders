# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsidyRule, type: :model do
  it { should belong_to(:county).optional }
  it { should belong_to(:state) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }

  it 'factory should be valid (default; no args)' do
    expect(build(:subsidy_rule_for_illinois)).to be_valid
  end

  it do
    should define_enum_for(:license_type).with_values(
      Licenses.types
    ).backed_by_column_of_type(:enum)
  end

  let(:illinois) { create(:state, name: 'Illinois') }
  let(:cook_county) { create(:county, name: 'Cook', state: illinois) }
  let(:lake_county) { create(:county, name: 'Lake', state: illinois) }
  let(:il_subsidy_rule) { create(:illinois_subsidy_rule) }
  let(:today) { Date.current }
  let(:eff_now_start) { today - 200.days }

  describe '.in_effect_on' do
    it 'default is Date.current' do
      effective_now = described_class.create!(name: 'Effective now',
                                              max_age: 18,
                                              license_type: Licenses.types.values.sample,
                                              county: cook_county,
                                              state: cook_county.state,
                                              effective_on: eff_now_start,
                                              expires_on: eff_now_start + 1.year - 1.day,
                                              subsidy_ruleable: il_subsidy_rule)
      described_class.create!(name: 'Last year',
                              max_age: 18,
                              license_type: Licenses.types.values.sample,
                              county: cook_county,
                              state: cook_county.state,
                              effective_on: eff_now_start - 1.year,
                              expires_on: eff_now_start - 1.day,
                              subsidy_ruleable: il_subsidy_rule)
      expect(described_class.in_effect_on).to match_array([effective_now])
    end

    it 'has not expired as of the date' do
      effective_now = described_class.create!(name: 'Effective now',
                                              max_age: 18,
                                              license_type: Licenses.types.values.sample,
                                              county: cook_county,
                                              state: cook_county.state,
                                              effective_on: eff_now_start,
                                              expires_on: eff_now_start + 1.year - 1.day,
                                              subsidy_ruleable: il_subsidy_rule)

      expect(described_class.in_effect_on(effective_now.expires_on)).to be_empty
    end

    it 'effective on or before the date' do
      effective_now = described_class.create!(name: 'Effective now',
                                              max_age: 18,
                                              license_type: Licenses.types.values.sample,
                                              county: cook_county,
                                              state: cook_county.state,
                                              effective_on: eff_now_start,
                                              expires_on: eff_now_start + 1.year - 1.day,
                                              subsidy_ruleable: il_subsidy_rule)

      expect(described_class.in_effect_on(eff_now_start))
        .to match_array([effective_now])
      expect(described_class.in_effect_on(eff_now_start + 1.day))
        .to match_array([effective_now])
    end
  end

  describe '.within_max_age' do
    it 'given age is less than or equal to the max age' do
      max6 = described_class.create!(name: 'Effective now',
                                     max_age: 6,
                                     license_type: Licenses.types.values.sample,
                                     county: cook_county,
                                     state: cook_county.state,
                                     effective_on: eff_now_start,
                                     expires_on: eff_now_start + 1.year - 1.day,
                                     subsidy_ruleable: il_subsidy_rule)
      max18 = described_class.create!(name: 'Effective now',
                                      max_age: 18,
                                      license_type: Licenses.types.values.sample,
                                      county: cook_county,
                                      state: cook_county.state,
                                      effective_on: eff_now_start,
                                      expires_on: eff_now_start + 1.year - 1.day,
                                      subsidy_ruleable: il_subsidy_rule)

      expect(described_class.within_max_age(5)).to match_array([max6, max18])
      expect(described_class.within_max_age(6)).to match_array([max6, max18])
      expect(described_class.within_max_age(7)).to match_array([max18])
    end

    it 'is a list ordered by max_age, with smallest max_age first' do
      max6 = described_class.create!(name: 'Effective now',
                                     max_age: 6,
                                     license_type: Licenses.types.values.sample,
                                     county: cook_county,
                                     state: cook_county.state,
                                     effective_on: eff_now_start,
                                     expires_on: eff_now_start + 1.year - 1.day,
                                     subsidy_ruleable: il_subsidy_rule)
      described_class.create!(name: 'Effective now',
                              max_age: 12,
                              license_type: Licenses.types.values.sample,
                              county: cook_county,
                              state: cook_county.state,
                              effective_on: eff_now_start,
                              expires_on: eff_now_start + 1.year - 1.day,
                              subsidy_ruleable: il_subsidy_rule)
      max18 = described_class.create!(name: 'Effective now',
                                      max_age: 18,
                                      license_type: Licenses.types.values.sample,
                                      county: cook_county,
                                      state: cook_county.state,
                                      effective_on: eff_now_start,
                                      expires_on: eff_now_start + 1.year - 1.day,
                                      subsidy_ruleable: il_subsidy_rule)
      result = described_class.within_max_age(5)
      expect(result.first).to eq max6
      expect(result.last).to eq max18
    end
  end

  describe '.age_county_state' do
    it 'is effective on the given date' do
      given_date = Date.current - 100
      expect(described_class).to receive(:in_effect_on).with(given_date)
                                                       .and_call_original
      described_class.age_county_state(8, cook_county, illinois,
                                       effective_on: given_date)
    end

    it 'is within the max age' do
      expect(described_class).to receive(:within_max_age).with(8.2)
                                                         .and_call_original
      described_class.age_county_state(8.2, cook_county, illinois)
    end

    it 'for the state and county' do
      described_class.create!(name: 'Effective now',
                              max_age: 18,
                              license_type: Licenses.types.values.sample,
                              county: cook_county,
                              state: cook_county.state,
                              effective_on: eff_now_start,
                              expires_on: eff_now_start + 1.year - 1.day,
                              subsidy_ruleable: il_subsidy_rule)
      lake_cty = described_class.create!(name: 'Effective now',
                                         max_age: 18,
                                         license_type: Licenses.types.values.sample,
                                         county: lake_county,
                                         state: lake_county.state,
                                         effective_on: eff_now_start,
                                         expires_on: eff_now_start + 1.year - 1.day,
                                         subsidy_ruleable: il_subsidy_rule)
      expect(described_class.age_county_state(8, lake_county, illinois))
        .to eq lake_cty
    end

    it 'returns the first result' do
      described_class.create!(name: 'Effective now',
                              max_age: 6,
                              license_type: Licenses.types.values.sample,
                              county: cook_county,
                              state: cook_county.state,
                              effective_on: eff_now_start,
                              expires_on: eff_now_start + 1.year - 1.day,
                              subsidy_ruleable: il_subsidy_rule)
      max18 = described_class.create!(name: 'Effective now',
                                      max_age: 18,
                                      license_type: Licenses.types.values.sample,
                                      county: cook_county,
                                      state: cook_county.state,
                                      effective_on: eff_now_start,
                                      expires_on: eff_now_start + 1.year - 1.day,
                                      subsidy_ruleable: il_subsidy_rule)
      expect(described_class.age_county_state(17.05, cook_county, illinois))
        .to eq max18
    end
  end
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                    :uuid             not null, primary key
#  effective_on          :date
#  expires_on            :date
#  license_type          :enum             not null
#  max_age               :decimal(, )      not null
#  name                  :string           not null
#  subsidy_ruleable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  county_id             :uuid
#  state_id              :uuid             not null
#  subsidy_ruleable_id   :uuid
#
# Indexes
#
#  index_subsidy_rules_on_county_id               (county_id)
#  index_subsidy_rules_on_state_id                (state_id)
#  index_subsidy_rules_on_state_id_and_county_id  (state_id,county_id)
#  subsidy_ruleable_index                         (subsidy_ruleable_type,subsidy_ruleable_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (state_id => states.id)
#
