# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisSubsidyRule, type: :model do
  it { should have_one(:subsidy_rule) }

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
#  gold_percentage   :decimal(, )
#  silver_percentage :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
