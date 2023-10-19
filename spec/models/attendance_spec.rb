# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance do
  before { travel_to '2022-06-01'.to_date }

  after  { travel_back }

  let(:service_day) { create(:service_day) }
  let(:now) { Time.current }
  let(:child_approval) { service_day.child.child_approvals.first }
  let(:attendance) { build(:attendance, check_out: nil, service_day:, child_approval:) }

  it { is_expected.to belong_to(:child_approval) }

  it { is_expected.to validate_presence_of(:check_in) }

  # this needs to get moved to the custom validator specs instead of inside models
  it 'validates check_in as a Time' do
    attendance.update(check_in: now)
    expect(attendance).to be_valid
    attendance.check_in = "I'm a string"
    expect(attendance).not_to be_valid
    attendance.check_in = nil
    expect(attendance).not_to be_valid
    attendance.check_in = now.strftime('%Y-%m-%d %I:%M%P')
    expect(attendance).to be_valid
    attendance.check_in = now.to_date
    expect(attendance).to be_valid
  end

  # this needs to get moved to the custom validator specs instead of inside models
  it 'validates check_out as an optional Time' do
    attendance.update(check_out: now)
    expect(attendance).to be_valid
    attendance.check_out = "I'm a string"
    expect(attendance).not_to be_valid
    attendance.check_out = nil
    expect(attendance).to be_valid
    attendance.check_out = now.strftime('%Y-%m-%d %I:%M%P')
    expect(attendance).to be_valid
    attendance.check_in = now.to_date - 2.hours
    attendance.check_out = now.to_date
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
    service_day = create(:service_day)
    expect(build(:attendance, service_day:)).to be_valid
  end

  context 'with date scopes' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) do
      service_day = create(:service_day, date: now.at_beginning_of_day)
      create(:attendance, check_in: now, child_approval:, service_day:)
    end
    let(:past_attendance) do
      time = Time.new(2020, 12, 1, 9, 31, 0, timezone)
      service_day = create(:service_day, date: time.at_beginning_of_day)
      create(:attendance,
             child_approval:,
             service_day:,
             check_in: time,
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
      let(:time) { Faker::Time.between(from: now.at_beginning_of_week(:sunday), to: now) }
      let(:service_day) do
        create(
          :service_day,
          date: time.at_beginning_of_day,
          child: child_approval.child
        )
      end
      let(:current_attendance) do
        create(
          :attendance,
          check_in: time,
          service_day:,
          child_approval:
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
    let(:child) { create(:child, businesses: [create(:business, zipcode: '60606')]) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:part_day) do
      time = Time.new(2020, 12, 1, 9, 31, 0, timezone)
      service_day = create(:service_day, date: time.at_beginning_of_day, child:)
      create(:attendance,
             child_approval:,
             service_day:,
             check_in: time,
             check_out: Time.new(2020, 12, 1, 13, 30, 0, timezone))
    end
    let(:full_day) do
      time = Time.new(2020, 12, 2, 9, 31, 0, timezone)
      service_day = create(:service_day, date: time.at_beginning_of_day, child:)
      create(:attendance,
             child_approval:,
             service_day:,
             check_in: time,
             check_out: Time.new(2020, 12, 2, 21, 31, 0, timezone))
    end
    let(:full_plus_part_day) do
      time = Time.new(2020, 12, 3, 9, 31, 0, timezone)
      service_day = create(:service_day, date: time.at_beginning_of_day, child:)
      create(:attendance,
             child_approval:,
             service_day:,
             check_in: time,
             check_out: Time.new(2020, 12, 3, 21, 32, 0, timezone))
    end
    let(:full_plus_full_day) do
      time = Time.new(2020, 12, 4, 9, 31, 0, timezone)
      service_day = create(:service_day, date: time.at_beginning_of_day, child:)
      create(:attendance,
             child_approval:,
             service_day:,
             check_in: time,
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
      service_day = create(:service_day)
      attendance = create(:attendance,
                          check_out: nil,
                          service_day:,
                          child_approval: service_day.child.child_approvals.first)
      expect(attendance.time_in_care.seconds).to eq(0.seconds)
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
