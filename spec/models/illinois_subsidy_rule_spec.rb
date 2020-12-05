# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisSubsidyRule, type: :model do
  it { should have_one(:subsidy_rule).dependent(:restrict_with_error) }
  it { should validate_numericality_of(:bronze_percentage) }
  it { should validate_numericality_of(:full_day_rate) }
  it { should validate_numericality_of(:gold_percentage) }
  it { should validate_numericality_of(:part_day_rate) }
  it { should validate_numericality_of(:silver_percentage) }

  it 'factory should be valid (default; no args)' do
    expect(build(:illinois_subsidy_rule)).to be_valid
  end
end

# == Schema Information
#
# Table name: illinois_subsidy_rules
#
#  id                :uuid             not null, primary key
#  bronze_percentage :decimal(, )
#  full_day_rate     :decimal(, )
#  gold_percentage   :decimal(, )
#  part_day_rate     :decimal(, )
#  silver_percentage :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
