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
    attendance.check_in = Time.current.to_date - 2.hours
    attendance.check_out = Time.current.to_date
    expect(attendance).to be_valid
  end

  it 'validates that the check_out is after the check_in if it is present' do
    attendance.update(check_out: 90.years.ago)
    expect(attendance.errors.messages[:check_out]).to be_present
    attendance.update(check_out: 3.days.from_now)
    expect(attendance.errors.messages[:check_out]).not_to be_present
    attendance.update(check_out: nil)
    expect(attendance.errors.messages[:check_out]).not_to be_present
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:attendance)).to be_valid
  end

  context 'with date scopes' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) { create(:attendance, check_in: Time.current, child_approval: child_approval) }
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

  describe '#assign_new_service_day' do
    let!(:attendance) { create(:nebraska_hourly_attendance) }

    it 'creates a new service day when check_in time is changed to different day' do
      service_day_id = attendance.service_day.id
      attendance.update!(check_in: attendance.check_in + 1.day, check_out: attendance.check_out + 1.day)
      expect(attendance.service_day.id).not_to eq(service_day_id)
    end

    it 'keeps the same service day when check_in time update is still the same day' do
      service_day_id = attendance.service_day.id
      attendance.update!(check_in: attendance.check_in + 5.hours, check_out: attendance.check_out + 5.hours)
      expect(attendance.service_day.id).to eq(service_day_id)
    end

    it 'assigned to an existing service day when check_in time is changed to different day' do
      service_day = create(
        :service_day,
        date: attendance.check_in.in_time_zone(attendance.user.timezone).at_beginning_of_day - 1.day,
        child: attendance.child
      )
      attendance.update!(check_in: attendance.check_in - 1.day, check_out: attendance.check_out - 1.day)
      expect(attendance.service_day).to eq(service_day)
    end
  end

  describe '#remove_old_service_day' do
    let!(:attendance) { create(:nebraska_hourly_attendance) }

    it 'deletes old service day when updating to new date' do
      old_service_day_id = attendance.service_day.id
      create(
        :service_day,
        date: attendance.check_in.in_time_zone(attendance.user.timezone).at_beginning_of_day - 1.day,
        child: attendance.child
      )
      attendance.update!(check_in: attendance.check_in - 1.day, check_out: attendance.check_out - 1.day)
      expect(ServiceDay.find_by(id: old_service_day_id)).to be_nil
      expect(described_class.find_by(id: attendance.id)).to be_present
    end

    it 'does not delete old service day if it still has attendance' do
      old_service_day_id = attendance.service_day.id
      described_class.create!(
        check_in: attendance.check_in + 45.minutes,
        child_approval: attendance.child_approval,
        service_day: attendance.service_day
      )
      create(
        :service_day,
        date: attendance.check_in.in_time_zone(attendance.user.timezone).at_beginning_of_day - 1.day,
        child: attendance.child
      )
      attendance.update!(check_in: attendance.check_in - 1.day, check_out: attendance.check_out - 1.day)
      expect(ServiceDay.find_by(id: old_service_day_id)).to be_present
    end
  end

  describe '#delete_or_mark_absent' do
    let!(:attendance) { create(:nebraska_hourly_attendance) }

    it 'deletes the service day if this was the last attendance for that service day w/ no schedule' do
      service_day_id = attendance.service_day.id
      attendance&.service_day&.schedule&.destroy!
      attendance.service_day.reload
      attendance.destroy!
      ServiceDay.all.map(&:reload)
      expect(ServiceDay.all.pluck(:id)).not_to include(service_day_id)
    end

    it "doesn't delete the service day if this was the last attendance for that service day w/ a schedule" do
      service_day_id = attendance.service_day.id
      unless attendance.service_day.schedule
        attendance.service_day.update(
          schedule: create(:schedule,
                           weekday: attendance.wday,
                           effective_on: attendance - 5.days,
                           expires_on: nil)
        )
      end
      attendance.destroy!
      ServiceDay.all.map(&:reload)
      expect(ServiceDay.all.pluck(:id)).to include(service_day_id)
      expect(attendance.service_day.absence_type).to eq('absence')
    end

    it 'does not delete the service day if this was not the last attendance for that service day' do
      service_day_id = attendance.service_day.id
      create(:nebraska_hourly_attendance,
             child_approval: attendance.child_approval,
             check_in: attendance.check_in.in_time_zone(attendance.child.timezone).at_beginning_of_day + 3.hours,
             check_out: attendance.check_in.in_time_zone(attendance.child.timezone).at_beginning_of_day + 6.hours)
      attendance.destroy!
      ServiceDay.all.map(&:reload)
      expect(ServiceDay.all.pluck(:id)).to include(service_day_id)
    end
  end
end
# == Schema Information
#
# Table name: attendances
#
#  id                :uuid             not null, primary key
#  check_in          :datetime         not null
#  check_out         :datetime
#  deleted_at        :date
#  time_in_care      :interval         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  child_approval_id :uuid             not null
#  service_day_id    :uuid
#  wonderschool_id   :string
#
# Indexes
#
#  index_attendances_on_check_in           (check_in)
#  index_attendances_on_child_approval_id  (child_approval_id)
#  index_attendances_on_service_day_id     (service_day_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#  fk_rails_...  (service_day_id => service_days.id)
#
