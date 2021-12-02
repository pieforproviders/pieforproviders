# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDay, type: :model do
  let(:service_day) { build(:service_day) }

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

  it 'factory should be valid (default; no args)' do
    expect(build(:service_day)).to be_valid
  end

  # scopes
  context 'with absences scopes' do
    let(:absence) { create(:nebraska_absence, absence: 'absence') }
    let(:covid_absence) { create(:nebraska_absence, absence: 'covid_absence') }
    let(:attendance) { create(:nebraska_hourly_attendance) }

    it 'returns absences only' do
      expect(described_class.absences).to include(absence.service_day)
      expect(described_class.absences).to include(covid_absence.service_day)
      expect(described_class.absences).not_to include(attendance.service_day)
    end

    it 'returns non-absences only' do
      expect(described_class.non_absences).not_to include(absence.service_day)
      expect(described_class.non_absences).not_to include(covid_absence.service_day)
      expect(described_class.non_absences).to include(attendance.service_day)
    end

    it 'returns standard absences only' do
      expect(described_class.standard_absences).to include(absence.service_day)
      expect(described_class.standard_absences).not_to include(covid_absence.service_day)
      expect(described_class.standard_absences).not_to include(attendance.service_day)
    end

    it 'returns covid absences only' do
      expect(described_class.covid_absences).not_to include(absence.service_day)
      expect(described_class.covid_absences).to include(covid_absence.service_day)
      expect(described_class.covid_absences).not_to include(attendance.service_day)
    end
  end

  context 'with duration scopes' do
    let(:child) { create(:necc_child) }
    let(:child_approval) { child.child_approvals.first }
    let(:check_in) { Time.current.in_time_zone(child.timezone).at_beginning_of_day }
    let(:hourly) do
      create(
        :attendance,
        child_approval: child_approval,
        check_in: check_in,
        check_out: check_in + 2.hours
      )
    end
    let(:daily) do
      create(
        :attendance,
        child_approval: child_approval,
        check_in: check_in + 1.day,
        check_out: check_in + 1.day + 7.hours
      )
    end
    let(:daily_plus_hourly) do
      create(
        :attendance,
        child_approval: child_approval,
        check_in: check_in + 2.days,
        check_out: check_in + 2.days + 12.hours
      )
    end
    let(:daily_plus_hourly_max) do
      create(
        :attendance,
        child_approval: child_approval,
        check_in: check_in + 3.days,
        check_out: check_in + 3.days + 19.hours
      )
    end

    before do
      hourly.service_day.reload
      daily.service_day.reload
      daily_plus_hourly.service_day.reload
      daily_plus_hourly_max.service_day.reload
    end

    it 'returns hourly only' do
      expect(described_class.ne_hourly).to include(hourly.service_day)
      expect(described_class.ne_hourly).not_to include(daily.service_day)
      expect(described_class.ne_hourly).not_to include(daily_plus_hourly.service_day)
      expect(described_class.ne_hourly).not_to include(daily_plus_hourly_max.service_day)
      create(
        :attendance,
        child_approval: hourly.child_approval,
        check_in: hourly.check_in + 5.hours,
        check_out: hourly.check_in + 6.hours
      )
      expect(described_class.ne_hourly).to include(hourly.service_day)
      expect(described_class.ne_hourly).not_to include(daily.service_day)
      expect(described_class.ne_hourly).not_to include(daily_plus_hourly.service_day)
      expect(described_class.ne_hourly).not_to include(daily_plus_hourly_max.service_day)
    end

    it 'returns daily only' do
      expect(described_class.ne_daily).not_to include(hourly.service_day)
      expect(described_class.ne_daily).to include(daily.service_day)
      expect(described_class.ne_daily).not_to include(daily_plus_hourly.service_day)
      expect(described_class.ne_daily).not_to include(daily_plus_hourly_max.service_day)
      create(
        :attendance,
        child_approval: hourly.child_approval,
        check_in: hourly.check_in + 5.hours,
        check_out: hourly.check_in + 10.hours
      )
      expect(described_class.ne_daily).to include(hourly.service_day)
      expect(described_class.ne_daily).to include(daily.service_day)
      expect(described_class.ne_daily).not_to include(daily_plus_hourly.service_day)
      expect(described_class.ne_daily).not_to include(daily_plus_hourly_max.service_day)
    end

    it 'returns daily_plus_hourly only' do
      expect(described_class.ne_daily_plus_hourly).not_to include(hourly.service_day)
      expect(described_class.ne_daily_plus_hourly).not_to include(daily.service_day)
      expect(described_class.ne_daily_plus_hourly).to include(daily_plus_hourly.service_day)
      expect(described_class.ne_daily_plus_hourly).not_to include(daily_plus_hourly_max.service_day)
      create(
        :attendance,
        child_approval: hourly.child_approval,
        check_in: hourly.check_in + 5.hours,
        check_out: hourly.check_in + 16.hours
      )
      expect(described_class.ne_daily_plus_hourly).to include(hourly.service_day)
      expect(described_class.ne_daily_plus_hourly).not_to include(daily.service_day)
      expect(described_class.ne_daily_plus_hourly).to include(daily_plus_hourly.service_day)
      expect(described_class.ne_daily_plus_hourly).not_to include(daily_plus_hourly_max.service_day)
    end

    it 'returns daily_plus_hourly_max only' do
      expect(described_class.ne_daily_plus_hourly_max).not_to include(hourly.service_day)
      expect(described_class.ne_daily_plus_hourly_max).not_to include(daily.service_day)
      expect(described_class.ne_daily_plus_hourly_max).not_to include(daily_plus_hourly.service_day)
      expect(described_class.ne_daily_plus_hourly_max).to include(daily_plus_hourly_max.service_day)
      create(
        :attendance,
        child_approval: hourly.child_approval,
        check_in: hourly.check_in + 3.hours,
        check_out: hourly.check_in + 21.hours
      )
      expect(described_class.ne_daily_plus_hourly_max).to include(hourly.service_day)
      expect(described_class.ne_daily_plus_hourly_max).not_to include(daily.service_day)
      expect(described_class.ne_daily_plus_hourly_max).not_to include(daily_plus_hourly.service_day)
      expect(described_class.ne_daily_plus_hourly_max).to include(daily_plus_hourly_max.service_day)
    end
  end

  context 'with date scopes' do
    let(:child) { create(:child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_attendance) { create(:attendance, child_approval: child_approval) }
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
          check_in: Faker::Time.between(from: Time.current.at_beginning_of_week(:sunday), to: Time.current),
          child_approval: child_approval
        )
      end
      let(:date) { Time.new(2020, 12, 4, 0, 0, 0, timezone).to_date }

      it 'returns service days for given week' do
        expect(described_class.for_week).to include(current_service_day)
        expect(described_class.for_week).not_to include(past_service_day)
        expect(described_class.for_week(date)).to include(past_service_day)
        expect(described_class.for_week(date)).not_to include(current_service_day)
        expect(described_class.for_week(date - 1.week).size).to eq(0)
      end
    end

    describe '#for_day' do
      let(:date) { current_attendance.check_in.to_date }

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
end
# == Schema Information
#
# Table name: service_days
#
#  id         :uuid             not null, primary key
#  date       :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_service_days_on_child_id  (child_id)
#  index_service_days_on_date      (date)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
