# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  it { should belong_to(:child_case_cycle) }

  it { should allow_values(:part_day, :full_day, :full_plus_part_day, :full_plus_full_day).for(:length_of_care) }
  it {
    should define_enum_for(:length_of_care).with_values(
      described_class::LENGTHS_OF_CARE.index_by(&:to_sym)
    ).backed_by_column_of_type(:enum)
  }

  it 'validates uniqueness of slug' do
    create(:attendance)
    should validate_uniqueness_of(:slug)
  end

  it 'validates starts_on date if present' do
    attend = build(:attendance)
    expect(attend).to be_valid

    attend.starts_on = 10
    expect(attend).not_to be_valid
    expect(attend.errors[:starts_on]).to include(DateParamValidator.invalid_date_msg)

    attend.starts_on = Time.zone.today
    expect(attend).to be_valid
  end
end
