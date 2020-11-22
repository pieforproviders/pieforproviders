# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsidyRule, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_numericality_of(:max_age).is_greater_than_or_equal_to(0.00) }

  it 'factory should be valid (default; no args)' do
    expect(build(:subsidy_rule_for_illinois)).to be_valid
  end
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                    :uuid             not null, primary key
#  county                :string
#  effective_on          :date
#  expires_on            :date
#  license_type          :string           not null
#  max_age               :decimal(, )      not null
#  name                  :string           not null
#  state                 :string
#  subsidy_ruleable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  subsidy_ruleable_id   :bigint
#
# Indexes
#
#  subsidy_ruleable_index  (subsidy_ruleable_type,subsidy_ruleable_id)
#
