# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsidyRule, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to monetize(:full_day_rate) }
  it { should validate_numericality_of(:full_day_rate).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to monetize(:part_day_rate) }
  it { should validate_numericality_of(:part_day_rate).is_greater_than_or_equal_to(0.00) }

  it { is_expected.to validate_numericality_of(:full_day_max_hours).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:part_day_max_hours).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:full_day_threshold).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:part_day_threshold).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:full_plus_full_day_max_hours).is_greater_than_or_equal_to(0.00) }
  it { is_expected.to validate_numericality_of(:full_plus_part_day_max_hours).is_greater_than_or_equal_to(0.00) }

  it 'factory should be valid (default; no args)' do
    expect(build(:subsidy_rule)).to be_valid
  end

  it do
    should define_enum_for(:license_type).with_values(
      Licenses.types
    ).backed_by_column_of_type(:enum)
  end

  it 'qris rating can be nil' do
    subsidy_rule = build(:subsidy_rule)
    subsidy_rule.update(qris_rating: '1')
    expect(subsidy_rule.valid?).to be_truthy
    subsidy_rule.qris_rating = nil
    expect(subsidy_rule.valid?).to be_truthy
  end
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                           :uuid             not null, primary key
#  full_day_max_hours           :decimal(, )      not null
#  full_day_rate_cents          :integer          default(0), not null
#  full_day_rate_currency       :string           default("USD"), not null
#  full_day_threshold           :decimal(, )      not null
#  full_plus_full_day_max_hours :decimal(, )      not null
#  full_plus_part_day_max_hours :decimal(, )      not null
#  license_type                 :enum             not null
#  max_age                      :decimal(, )      not null
#  name                         :string           not null
#  part_day_max_hours           :decimal(, )      not null
#  part_day_rate_cents          :integer          default(0), not null
#  part_day_rate_currency       :string           default("USD"), not null
#  part_day_threshold           :decimal(, )      not null
#  qris_rating                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
