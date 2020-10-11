# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  it { should allow_values(:part_day, :full_day, :full_plus_part_day, :full_plus_full_day).for(:attendance_duration) }
  it {
    should define_enum_for(:attendance_duration).with_values(
      described_class::DURATION_DEFINITIONS.index_by(&:to_sym)
    ).backed_by_column_of_type(:enum)
  }

  it 'validates starts_on date if present' do
    attend = build(:attendance)
    expect(attend).to be_valid

    attend.starts_on = 10
    expect(attend).not_to be_valid
    expect(attend.errors[:starts_on]).to include(DateParamValidator.invalid_date_msg)

    attend.starts_on = Time.zone.today
    expect(attend).to be_valid
  end

  it 'calculates the total_time_in_care before validation' do
    attend = create(:attendance)
    expect(attend).to be_valid
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  attendance_duration                                            :enum             default("full_day"), not null
#  check_in                                                       :time             not null
#  check_out                                                      :time             not null
#  starts_on                                                      :date             not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#
