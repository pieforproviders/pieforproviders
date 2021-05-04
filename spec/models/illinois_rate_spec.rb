# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisRate, type: :model do
  it { should have_one(:rate).dependent(:restrict_with_error) }
  it { should validate_numericality_of(:bronze_percentage) }
  it { should validate_numericality_of(:full_day_rate) }
  it { should validate_numericality_of(:gold_percentage) }
  it { should validate_numericality_of(:part_day_rate) }
  it { should validate_numericality_of(:silver_percentage) }

  it 'factory should be valid (default; no args)' do
    expect(build(:illinois_rate)).to be_valid
  end
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                   :uuid             not null, primary key
#  attendance_threshold :decimal(, )
#  bronze_percentage    :decimal(, )
#  full_day_rate        :decimal(, )
#  gold_percentage      :decimal(, )
#  part_day_rate        :decimal(, )
#  silver_percentage    :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
