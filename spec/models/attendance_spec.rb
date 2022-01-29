# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:attendance) { build(:attendance, check_out: nil) }

  it { is_expected.to belong_to(:child_approval) }

  it { is_expected.to validate_presence_of(:check_in) }

  # this needs to get moved to the custom validator specs instead of inside models
  it 'validates check_in as a Time' do
    attendance.update(check_in: Time.current)
    expect(attendance).to be_valid
    attendance.check_in = "I'm a string"
    expect(attendance).not_to be_valid
    attendance.check_in = nil
    expect(attendance).not_to be_valid
    attendance.check_in = Time.current.strftime('%Y-%m-%d %I:%M%P')
    expect(attendance).to be_valid
    attendance.check_in = Time.current.to_date
    expect(attendance).to be_valid
  end

  # this needs to get moved to the custom validator specs instead of inside models
  it 'validates check_out as an optional Time' do
    attendance.update(check_out: Time.current)
    expect(attendance).to be_valid
    attendance.check_out = "I'm a string"
    expect(attendance).not_to be_valid
    attendance.check_out = nil
    expect(attendance).to be_valid
    attendance.check_out = Time.current.strftime('%Y-%m-%d %I:%M%P')
    expect(attendance).to be_valid
    attendance.check_out = Time.current.to_date
    expect(attendance).to be_valid
  end

  it 'validates that absence is a permitted value only' do
    attendance.check_in = Helpers.prior_weekday(attendance.check_in, 0)
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
    attendance.update(check_out: 90.years.ago)
    expect(attendance.errors.messages[:check_out]).to be_present
    attendance.update(check_out: 3.days.from_now)
    expect(attendance.errors.messages[:check_out]).not_to be_present
    attendance.update(check_out: nil)
    expect(attendance.errors.messages[:check_out]).not_to be_present
  end

  it 'validates that an absence only occurs on a scheduled day' do
    child = create(:necc_child)
    child.reload
    # ensures the attendance check in falls on the calendar weekday in the schedule
    attendance_check_in = Helpers.prior_weekday(child.schedules.first.effective_on + 30.days, 0)
    attendance = build(:nebraska_absence, child_approval: child.child_approvals.first, check_in: attendance_check_in)
    expect(attendance).not_to be_valid
  end

  it 'validates that there is only one absence per service day' do
    absence = create(:nebraska_absence)
    second_absence = build(:nebraska_absence,
      check_in: absence.check_in + 45.minutes,
      child_approval: absence.child_approval,
      service_day: absence.service_day
    )
    expect(second_absence).not_to be_valid
    expect(second_absence.errors.messages[:absence]).to include('there is already an absence for this date')
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:attendance)).to be_valid
  end

  context 'with date scopes' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) { create(:attendance, child_approval: child_approval) }
    let(:past_attendance) do
      create(:attendance,
             child_approval: child_approval,
             check_in: Time.new(2020, 12, 1, 9, 31, 0, timezone),
             check_out: Time.new(2020, 12, 1, 16, 56, 0, timezone))
    end

    describe '#for_month' do
      let(:date) { Time.new(2020, 12, 15, 0, 0, 0, timezone).to_date }

      it 'returns attendances for given month' do
        expect(described_class.for_month).to include(current_attendance)
        expect(described_class.for_month).not_to include(past_attendance)
        expect(described_class.for_month(date)).to include(past_attendance)
        expect(described_class.for_month(date)).not_to include(current_attendance)
        expect(described_class.for_month(date - 1.month).size).to eq(0)
      end
    end

    describe '#for_week' do
      let(:current_attendance) do
        create(
          :attendance,
          check_in: Faker::Time.between(from: Time.current.at_beginning_of_week(:sunday), to: Time.current),
          child_approval: child_approval
        )
      end
      let(:date) { Time.new(2020, 12, 4, 0, 0, 0, timezone).to_date }

      it 'returns attendances for given week' do
        expect(described_class.for_week).to include(current_attendance)
        expect(described_class.for_week).not_to include(past_attendance)
        expect(described_class.for_week(date)).to include(past_attendance)
        expect(described_class.for_week(date)).not_to include(current_attendance)
        expect(described_class.for_week(date - 1.week).size).to eq(0)
      end
    end

    describe '#for_day' do
      let(:date) { current_attendance.check_in.to_date }

      it 'returns attendances for given day' do
        travel_to date
        expect(described_class.for_day).to include(current_attendance)
        expect(described_class.for_day).not_to include(past_attendance)
        expect(described_class.for_day(date)).not_to include(past_attendance)
        expect(described_class.for_day(date)).to include(current_attendance)
        expect(described_class.for_day(date - 1.week).size).to eq(0)
        travel_back
      end
    end
  end

  describe '#illinois_*_days scopes' do
    let(:child) { create(:child, business: create(:business, zipcode: '60606')) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:part_day) do
      create(:attendance,
             child_approval: child_approval,
             check_in: Time.new(2020, 12, 1, 9, 31, 0, timezone),
             check_out: Time.new(2020, 12, 1, 13, 30, 0, timezone))
    end
    let(:full_day) do
      create(:attendance,
             child_approval: child_approval,
             check_in: Time.new(2020, 12, 2, 9, 31, 0, timezone),
             check_out: Time.new(2020, 12, 2, 21, 31, 0, timezone))
    end
    let(:full_plus_part_day) do
      create(:attendance,
             child_approval: child_approval,
             check_in: Time.new(2020, 12, 3, 9, 31, 0, timezone),
             check_out: Time.new(2020, 12, 3, 21, 32, 0, timezone))
    end
    let(:full_plus_full_day) do
      create(:attendance,
             child_approval: child_approval,
             check_in: Time.new(2020, 12, 4, 9, 31, 0, timezone),
             check_out: Time.new(2020, 12, 5, 2, 31, 0, timezone))
    end

    it 'returns attendances based on length of time in care' do
      expect(described_class.illinois_part_days).to include(part_day)
      expect(described_class.illinois_part_days).not_to include(
        [full_day, full_plus_part_day, full_plus_full_day]
      )
      expect(described_class.illinois_full_days).to include(full_day)
      expect(described_class.illinois_full_days).not_to include(
        [part_day, full_plus_part_day, full_plus_full_day]
      )
      expect(described_class.illinois_full_plus_part_days).to include(full_plus_part_day)
      expect(described_class.illinois_full_plus_part_days).not_to include(
        [part_day, full_day, full_plus_full_day]
      )
      expect(described_class.illinois_full_plus_full_days).to include(full_plus_full_day)
      expect(described_class.illinois_full_plus_full_days).not_to include(
        [part_day, full_day, full_plus_part_day]
      )
    end
  end

  describe '#time_in_care' do
    it 'uses the check_in and check_out when they are both present' do
      attendance.check_out = attendance.check_in + 3.hours + 12.minutes
      attendance.save!
      expect(attendance.time_in_care.in_seconds).to eq(attendance.check_out - attendance.check_in)
    end

    it 'returns 0 when missing a check_out' do
      attendance = create(:attendance, check_out: nil)
      expect(attendance.time_in_care.seconds).to eq(0.seconds)
    end
  end

  describe '#find_or_create_service_day' do
    it "creates a service day if it doesn't already exist" do
      expect { attendance.save! }.to change(ServiceDay, :count).from(0).to(1)
    end

    it 'associates to an existing service day' do
      service_day = create(
        :service_day,
        date: attendance.check_in.in_time_zone(attendance.user.timezone).at_beginning_of_day,
        child: attendance.child
      )
      service_day.reload
      expect { attendance.save! }.not_to change(ServiceDay, :count)
      expect(attendance.service_day).to eq(service_day)
    end

    it 'does not create a service day if no check-in is present' do
      attendance.check_in = nil
      expect { attendance.save }.not_to change(ServiceDay, :count)
    end
  end

  describe '#remove_absences' do
    it 'removes an absence on the same service day if it exists' do
      absence = create(:nebraska_absence)
      expect(described_class.absences.length).to eq(1)
      expect do
        described_class.create!(
          check_in: absence.check_in + 45.minutes,
          child_approval: absence.child_approval,
          service_day: absence.service_day
        )
      end.not_to change(ServiceDay, :count)
      expect(described_class.absences.length).to eq(0)
    end

    it 'removes an absence associated to the same child_approval on the same check_in day if it exists' do
      absence = create(:nebraska_absence)
      expect(described_class.absences.length).to eq(1)
      expect do
        described_class.create!(
          check_in: absence.check_in + 45.minutes,
          child_approval: absence.child_approval
        )
      end.not_to change(ServiceDay, :count)
      expect(described_class.absences.length).to eq(0)
    end

    it 'does not remove a non-absence from the same day' do
      attendance = create(:nebraska_hourly_attendance)
      expect(described_class.absences.length).to eq(0)
      expect(described_class.non_absences.length).to eq(1)
      expect do
        described_class.create!(
          check_in: attendance.check_in + 45.minutes,
          child_approval: attendance.child_approval
        )
      end.not_to change(ServiceDay, :count)
      expect(described_class.absences.length).to eq(0)
      expect(described_class.non_absences.length).to eq(2)
    end
  end

  describe '#remove_other_attendances' do
    let!(:attendance) { create(:nebraska_hourly_attendance) }

    it 'removes other attendances on the same service day if absence is created' do
      expect(described_class.non_absences.length).to eq(1)
      expect do
        described_class.create!(
          check_in: attendance.check_in + 45.minutes,
          child_approval: attendance.child_approval,
          service_day: attendance.service_day,
          absence: 'absence'
        )
      end.not_to change(ServiceDay, :count)
      expect(described_class.absences.length).to eq(1)
      expect(described_class.non_absences.length).to eq(0)
    end

    it 'removes other attendance on the same service day if attendance is updated to absence' do
      described_class.create!(
        check_in: attendance.check_in + 45.minutes,
        child_approval: attendance.child_approval,
        service_day: attendance.service_day
      )
      expect(described_class.non_absences.length).to eq(2)
      attendance.update(absence: 'absence')
      expect(described_class.absences.length).to eq(1)
      expect(described_class.non_absences.length).to eq(0)
    end
  end
end
# == Schema Information
#
# Table name: attendances
#
#  id                                                       :uuid             not null, primary key
#  absence                                                  :string
#  check_in                                                 :datetime         not null
#  check_out                                                :datetime
#  deleted_at                                               :date
#  time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                               :datetime         not null
#  updated_at                                               :datetime         not null
#  child_approval_id                                        :uuid             not null
#  service_day_id                                           :uuid
#  wonderschool_id                                          :string
#
# Indexes
#
#  index_attendances_on_absence            (absence)
#  index_attendances_on_check_in           (check_in)
#  index_attendances_on_child_approval_id  (child_approval_id)
#  index_attendances_on_service_day_id     (service_day_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#  fk_rails_...  (service_day_id => service_days.id)
#
