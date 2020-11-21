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
#  subsidy_ruleable_id   :bigint
#
# Indexes
#
#  index_subsidy_rules_on_county_id  (county_id)
#  index_subsidy_rules_on_state_id   (state_id)
#  subsidy_ruleable_index            (subsidy_ruleable_type,subsidy_ruleable_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (state_id => states.id)
#
