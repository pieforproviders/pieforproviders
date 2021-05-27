# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  it { should belong_to(:child_approval) }

  it 'calculates the total_time_in_care before validation' do
    attend = create(:attendance, child_approval: create(:child_approval))
    expect(attend).to be_valid
  end

  context 'for_month scope' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) { create(:attendance, child_approval: child_approval) }
    let(:past_attendance) do
      create(:attendance, child_approval: child_approval, check_in: Time.new(2020, 12, 1, 9, 31, 0, timezone),
                          check_out: Time.new(2020, 12, 1, 16, 56, 0, timezone))
    end
    it 'returns attendances for given months' do
      date = Time.new(2020, 12, 15, 0, 0, 0, timezone).to_date
      expect(Attendance.for_month).to include(current_attendance)
      expect(Attendance.for_month).not_to include(past_attendance)
      expect(Attendance.for_month(date)).to include(past_attendance)
      expect(Attendance.for_month(date)).not_to include(current_attendance)
      expect(Attendance.for_month(date - 1.month).size).to eq(0)
    end
  end

  context 'illinois day length scopes' do
    let(:child) { create(:child, business: create(:business, zipcode: '60606')) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:part_day) do
      create(:attendance, child_approval: child_approval, check_in: Time.new(2020, 12, 1, 9, 31, 0, timezone),
                          check_out: Time.new(2020, 12, 1, 13, 30, 0, timezone))
    end
    let(:full_day) do
      create(:attendance, child_approval: child_approval, check_in: Time.new(2020, 12, 2, 9, 31, 0, timezone),
                          check_out: Time.new(2020, 12, 2, 21, 31, 0, timezone))
    end
    let(:full_plus_part_day) do
      create(:attendance, child_approval: child_approval, check_in: Time.new(2020, 12, 3, 9, 31, 0, timezone),
                          check_out: Time.new(2020, 12, 3, 21, 32, 0, timezone))
    end
    let(:full_plus_full_day) do
      create(:attendance, child_approval: child_approval, check_in: Time.new(2020, 12, 4, 9, 31, 0, timezone),
                          check_out: Time.new(2020, 12, 5, 2, 31, 0, timezone))
    end
    it 'returns attendances based on length of time in care' do
      expect(Attendance.illinois_part_days).to include(part_day)
      expect(Attendance.illinois_part_days).not_to include([full_day, full_plus_part_day, full_plus_full_day])
      expect(Attendance.illinois_full_days).to include(full_day)
      expect(Attendance.illinois_full_days).not_to include([part_day, full_plus_part_day, full_plus_full_day])
      expect(Attendance.illinois_full_plus_part_days).to include(full_plus_part_day)
      expect(Attendance.illinois_full_plus_part_days).not_to include([part_day, full_day, full_plus_full_day])
      expect(Attendance.illinois_full_plus_full_days).to include(full_plus_full_day)
      expect(Attendance.illinois_full_plus_full_days).not_to include([part_day, full_day, full_plus_part_day])
    end
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#  wonderschool_id                                                :string
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
