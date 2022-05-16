# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDay, type: :model do
  let(:service_day) { build(:service_day) }

  it 'factory should be valid (default; no args)' do
    expect(service_day).to be_valid
  end

  it { is_expected.to belong_to(:child) }
  it { is_expected.to validate_presence_of(:date) }

  it 'validates date as a datetime' do
    service_day.update(date: Time.current)
    expect(service_day).to be_valid
    service_day.date = DateTime.new(2021, 12, 11)
    expect(service_day).to be_valid
    service_day.date = '2021-02-01'
    expect(service_day).to be_valid
    service_day.date = Date.new(2021, 12, 11)
    expect(service_day).to be_valid
    service_day.date = "I'm a string"
    expect(service_day).not_to be_valid
    service_day.date = nil
    expect(service_day).not_to be_valid
  end

  it 'validates that absence_type is a permitted value only' do
    service_day.date = Helpers.prior_weekday(Time.current, 0)
    service_day.save!

    service_day.absence_type = 'covid_absence'
    expect(service_day).not_to be_valid
    expect(service_day.errors.messages[:absence_type]).to include("can't create for a day without a schedule")

    absence = build(:service_day, child: service_day.child, absence_type: 'covid_absence')
    expect(absence).to be_valid
    expect(absence.errors.messages).to eq({})

    absence = build(:service_day, child: service_day.child, absence_type: 'fake_reason')
    expect(absence).not_to be_valid
    expect(absence.errors.messages[:absence_type]).to include('is not included in the list')
  end

  # scopes
  context 'with absences scopes' do
    let(:absence) { create(:service_day, absence_type: 'absence') }
    let(:covid_absence) { create(:service_day, absence_type: 'covid_absence') }
    let(:attendance) { create(:service_day) }

    it 'returns absences only' do
      expect(described_class.absences).to include(absence)
      expect(described_class.absences).to include(covid_absence)
      expect(described_class.absences).not_to include(attendance)
    end

    it 'returns non-absences only' do
      expect(described_class.non_absences).not_to include(absence)
      expect(described_class.non_absences).not_to include(covid_absence)
      expect(described_class.non_absences).to include(attendance)
    end

    it 'returns standard absences only' do
      expect(described_class.standard_absences).to include(absence)
      expect(described_class.standard_absences).not_to include(covid_absence)
      expect(described_class.standard_absences).not_to include(attendance)
    end

    it 'returns covid absences only' do
      expect(described_class.covid_absences).not_to include(absence)
      expect(described_class.covid_absences).to include(covid_absence)
      expect(described_class.covid_absences).not_to include(attendance)
    end
  end

  context 'with date scopes' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) { create(:attendance, check_in: Time.current, child_approval: child_approval) }
    let(:current_service_day) { current_attendance.service_day }
    let(:past_attendance) do
      create(
        :attendance,
        child_approval: child_approval,
        check_in: Time.new(2020, 12, 1, 9, 31, 0, timezone),
        check_out: Time.new(2020, 12, 1, 16, 56, 0, timezone)
      )
    end
    let(:past_service_day) { past_attendance.service_day }

    describe '#for_month' do
      let(:date) { Time.new(2020, 12, 15, 0, 0, 0, timezone).to_date }

      it 'returns service days for given month' do
        expect(described_class.for_month).to include(current_service_day)
        expect(described_class.for_month).not_to include(past_service_day)
        expect(described_class.for_month(date)).to include(past_service_day)
        expect(described_class.for_month(date)).not_to include(current_service_day)
        expect(described_class.for_month(date - 1.month).size).to eq(0)
      end
    end

    describe '#for_week' do
      let(:current_attendance) do
        create(
          :attendance,
          check_in: Time.current.at_beginning_of_week(:sunday) + 2.days + 11.hours,
          child_approval: child_approval
        )
      end
      let(:date) { Time.new(2020, 12, 4, 0, 0, 0, timezone).to_date }

      it 'returns service days for given week' do
        travel_to Time.current.at_end_of_week(:sunday)
        expect(described_class.for_week).to include(current_service_day)
        expect(described_class.for_week).not_to include(past_service_day)
        expect(described_class.for_week(date)).to include(past_service_day)
        expect(described_class.for_week(date)).not_to include(current_service_day)
        expect(described_class.for_week(date - 1.week).size).to eq(0)
        travel_back
      end
    end

    describe '#for_day' do
      let(:date) { current_attendance.check_in.in_time_zone(child.timezone).to_date }

      it 'returns service days for given day' do
        travel_to date
        expect(described_class.for_day).to include(current_service_day)
        expect(described_class.for_day).not_to include(past_service_day)
        expect(described_class.for_day(date)).not_to include(past_service_day)
        expect(described_class.for_day(date)).to include(current_service_day)
        expect(described_class.for_day(date - 1.week).size).to eq(0)
        travel_back
      end
    end
  end

  describe '#total_time_in_care' do
    let(:attendance) { create(:nebraska_hourly_attendance, check_out: nil) }
    let(:service_day) { attendance.service_day }

    it 'calculates the right total when the service day is changed to an absence' do
      attendance.update!(check_out: attendance.check_in + 6.hours)
      service_day.update!(schedule: create(:schedule, weekday: service_day.date.wday, duration: 10.minutes))
      service_day.update!(absence_type: 'absence')
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(10.minutes)
    end

    it 'calculates the right total when the service day is changed from an absence back to a non-absence' do
      attendance.update!(check_out: attendance.check_in + 6.hours)
      service_day.update!(schedule: create(:schedule, weekday: service_day.date.wday, duration: 10.minutes))
      service_day.update!(absence_type: 'absence')
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(10.minutes)
      service_day.update!(absence_type: nil)
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(6.hours)
    end

    it 'for a single check-in with no check-out, returns the scheduled duration if the day has a schedule' do
      attendance.child.reload
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(attendance.child.schedules.first.duration)
    end

    it 'for a single check-in with no check-out, returns 8 hours if day has no schedule' do
      attendance.child.schedules.destroy_all
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(8.hours)
    end

    it 'for multiple check-ins with and without check-outs, returns scheduled duration if total is less' do
      create(
        :attendance,
        child_approval: attendance.child.child_approvals.first,
        check_in: attendance.check_in + 1.hour + 30.minutes,
        check_out: attendance.check_in + 3.hours + 30.minutes
      )
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(attendance.child.schedules.first.duration)
    end

    it 'for multiple check-ins with and without check-outs, returns attended duration if total is more' do
      create(
        :attendance,
        child_approval: attendance.child.child_approvals.first,
        check_in: attendance.check_in + 1.hour + 30.minutes,
        check_out: attendance.check_in + 10.hours + 30.minutes
      )
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(9.hours)
    end

    it 'with one or more check-ins, and none have a check-out, returns scheduled duration' do
      create(
        :attendance,
        child_approval: attendance.child.child_approvals.first,
        check_in: attendance.check_in + 3.hours + 30.minutes,
        check_out: nil
      )
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(attendance.child.schedules.first.duration)
    end
  end

  describe '#tag_hourly_amount' do
    it 'returns correct hourly amount if decimal' do
      attendance = create(:nebraska_hourly_attendance)
      service_day = attendance.service_day
      attendance.child.reload
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.tag_hourly_amount).to eq('5.5')
    end

    it 'returns correct hourly amount if integer' do
      attendance = create(:nebraska_hour_attendance)
      service_day = attendance.service_day
      attendance.child.reload
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.tag_hourly_amount).to eq('1')
    end
  end

  describe '#tag_daily_amount' do
    let(:attendance) { create(:nebraska_daily_attendance) }
    let(:service_day) { attendance.service_day }

    it 'returns correct daily amount' do
      attendance.child.reload
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.tag_daily_amount).to eq('1')
    end
  end
end
# == Schema Information
#
# Table name: service_days
#
#  id                      :uuid             not null, primary key
#  absence_type            :string
#  date                    :datetime         not null
#  earned_revenue_cents    :integer
#  earned_revenue_currency :string           default("USD"), not null
#  total_time_in_care      :interval
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  child_id                :uuid             not null
#  schedule_id             :uuid
#
# Indexes
#
#  index_service_days_on_child_id     (child_id)
#  index_service_days_on_date         (date)
#  index_service_days_on_schedule_id  (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
