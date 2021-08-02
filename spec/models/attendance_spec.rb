# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  it { should belong_to(:child_approval) }

  it { should validate_presence_of(:check_in) }

  let(:attendance) { build(:attendance, check_out: nil) }
  it 'validates check_in as a Time' do
    attendance.update(check_in: Time.zone.now)
    expect(attendance.valid?).to be_truthy
    attendance.check_in = "I'm a string"
    expect(attendance.valid?).to be_falsey
    attendance.check_in = nil
    expect(attendance.valid?).to be_falsey
    attendance.check_in = Time.zone.now.strftime('%Y-%m-%d %I:%M%P')
    expect(attendance.valid?).to be_truthy
    attendance.check_in = Date.new(2021, 12, 11)
    expect(attendance.valid?).to be_truthy
  end

  it 'validates check_out as an optional Time' do
    attendance.update(check_out: Time.zone.now)
    expect(attendance.valid?).to be_truthy
    attendance.check_out = "I'm a string"
    expect(attendance.valid?).to be_falsey
    attendance.check_out = nil
    expect(attendance.valid?).to be_truthy
    attendance.check_out = Time.zone.now.strftime('%Y-%m-%d %I:%M%P')
    expect(attendance.valid?).to be_truthy
    attendance.check_out = Date.new(2021, 12, 11)
    expect(attendance.valid?).to be_truthy
  end

  it 'validates that absence is a permitted value only' do
    attendance.save!

    attendance.absence = 'covid_absence'
    expect(attendance).not_to be_valid
    expect(attendance.errors.messages[:absence]).to include("can't create for a day without a schedule")

    absence = create(:nebraska_absence, absence: 'covid_absence')
    expect(absence).to be_valid
    expect(absence.errors.messages).to eq({})

    absence = build(:nebraska_absence, absence: 'fake_reason')
    expect(absence).not_to be_valid
    expect(absence.errors.messages[:absence]).to include('is not included in the list')
  end

  it 'validates that the check_out is after the check_in if it is present' do
    attendance.update(check_out: Time.current - 90.years)
    expect(attendance.errors.messages[:check_out]).to be_present
    attendance.update(check_out: Time.current + 3.days)
    expect(attendance.errors.messages[:check_out]).not_to be_present
    attendance.update(check_out: nil)
    expect(attendance.errors.messages[:check_out]).not_to be_present
  end

  it 'validates that an absence only occurs on a scheduled day' do
    child = create(:necc_child)
    # ensures the attendance check in falls on the calendar weekday in the schedule
    attendance_check_in = prior_weekday(child.schedules.first.effective_on + 30.days, child.schedules.first.weekday + 1)
    attendance = build(:nebraska_absence, child_approval: child.child_approvals.first, check_in: attendance_check_in)
    expect(attendance).not_to be_valid
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:attendance)).to be_valid
  end

  context 'calculates time in care' do
    it 'uses the check_in and check_out when they are both present' do
      attendance.check_out = attendance.check_in + 3.hours + 12.minutes
      attendance.save!
      expect(attendance.total_time_in_care.in_seconds).to eq(attendance.check_out - attendance.check_in)
    end
    it 'uses the check_in and schedule when check_out is null and the child has a schedule' do
      child = create(:necc_child)
      # ensures the attendance check in falls on the calendar weekday in the schedule
      attendance_check_in = prior_weekday(child.schedules.first.effective_on + 30.days, child.schedules.first.weekday)
      attendance = create(:attendance, child_approval: child.child_approvals.first, check_in: attendance_check_in, check_out: nil)
      expect(attendance.total_time_in_care.in_seconds).to eq(Tod::Shift.new(child.schedules.first.start_time, child.schedules.first.end_time).duration)
    end
    it 'uses the check_in and makes the attendance 8 hours when check_out is null and the child has no schedule' do
      child = create(:necc_child)
      child.schedules.destroy_all
      attendance = create(:attendance, child_approval: child.child_approvals.first, check_out: nil)
      expect(attendance.total_time_in_care.in_seconds).to eq(8.hours.in_seconds)
    end
    it 'uses the check_in and schedule when creating an absence' do
      child = create(:necc_child)
      # ensures the attendance check in falls on the calendar weekday in the schedule
      attendance_check_in = prior_weekday(child.schedules.first.effective_on + 30.days, child.schedules.first.weekday)
      attendance = create(:nebraska_absence, child_approval: child.child_approvals.first, check_in: attendance_check_in)
      expect(attendance.total_time_in_care.in_seconds).to eq(Tod::Shift.new(child.schedules.first.start_time, child.schedules.first.end_time).duration)
    end
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

  context 'for_week scope' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) do
      create(:attendance, check_in: Faker::Time.between(from: Time.current.at_beginning_of_week(:sunday), to: Time.current), child_approval: child_approval)
    end
    let(:past_attendance) do
      create(:attendance, child_approval: child_approval, check_in: Time.new(2020, 12, 1, 9, 31, 0, timezone),
                          check_out: Time.new(2020, 12, 1, 16, 56, 0, timezone))
    end
    it 'returns attendances for given weeks' do
      date = Time.new(2020, 12, 4, 0, 0, 0, timezone).to_date
      expect(Attendance.for_week).to include(current_attendance)
      expect(Attendance.for_week).not_to include(past_attendance)
      expect(Attendance.for_week(date)).to include(past_attendance)
      expect(Attendance.for_week(date)).not_to include(current_attendance)
      expect(Attendance.for_week(date - 1.week).size).to eq(0)
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
#  absence                                                        :string
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
