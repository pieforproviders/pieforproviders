# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDay, type: :model do
  let(:schedule) { create(:schedule, weekday: 1, expires_on: 1.year.from_now) }
  let(:child) { schedule.child }
  let(:service_day) { build(:service_day, child: child) }

  it 'factory should be valid (default; no args)' do
    expect(service_day).to be_valid
  end

  it { is_expected.to belong_to(:child) }
  it { is_expected.to validate_presence_of(:date) }

  it 'validates the uniqueness of child_id scoped to date' do
    expect(service_day).to validate_uniqueness_of(:child).scoped_to(:date)
  end

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
    expect(service_day).to be_valid
    expect(service_day.errors.messages[:absence_type]).not_to include("can't create for a day without a schedule")

    absence = build(
      :service_day,
      child: child,
      absence_type: 'covid_absence',
      date: Helpers.prior_weekday(Time.current, 1).in_time_zone(child.timezone).at_beginning_of_day
    )
    expect(absence).to be_valid
    expect(absence.errors.messages).to eq({})

    absence = build(
      :service_day,
      child: child,
      absence_type: 'absence',
      date: Helpers.prior_weekday(Time.current, 1).in_time_zone(child.timezone).at_beginning_of_day
    )

    expect(absence).to be_valid
    expect(absence.errors.messages).to eq({})

    absence = build(
      :service_day,
      child: child,
      absence_type: 'fake_reason',
      date: Helpers.prior_weekday(Time.current, 1).in_time_zone(child.timezone).at_beginning_of_day
    )
    expect(absence).not_to be_valid
    expect(absence.errors.messages[:absence_type]).to include('is not included in the list')
  end

  context 'with absence types' do
    let(:type_schedule) { create(:schedule, weekday: 1, expires_on: 1.year.from_now) }
    let(:type_child) { schedule.child }

    before do
      type_child.schedules.where(weekday: [2, 3, 4, 5, 6, 7]).destroy_all
      type_child.reload
    end

    describe '#set_absence_type_by_schedule' do
      let(:unscheduled_absence) do
        create(
          :service_day,
          child: type_child,
          absence_type: 'absence',
          date: Helpers.prior_weekday(Time.current, 2).in_time_zone(child.timezone).at_beginning_of_day
        )
      end
      let(:scheduled_absence) do
        create(
          :service_day,
          child: type_child,
          absence_type: 'absence',
          date: Helpers.prior_weekday(Time.current, 1).in_time_zone(child.timezone).at_beginning_of_day
        )
      end

      it 'changes absence type of unscheduled days to absence_on_unscheduled_day' do
        expect(unscheduled_absence.absence_type).to eq('absence_on_unscheduled_day')
      end

      it 'changes absence type of scheduled days to absence_on_scheduled_day' do
        expect(scheduled_absence.absence_type).to eq('absence_on_scheduled_day')
      end
    end
  end

  # scopes
  context 'with absences scopes' do
    let!(:absence) do
      create(
        :service_day,
        child: child,
        absence_type: 'absence',
        date: Helpers.prior_weekday(Time.current, 1).in_time_zone(child.timezone).at_beginning_of_day
      )
    end
    let!(:covid_absence) do
      create(
        :service_day,
        child: child,
        absence_type: 'covid_absence',
        date: Helpers.prior_weekday(Time.current, 2).in_time_zone(child.timezone).at_beginning_of_day
      )
    end

    let!(:service_day_with_attendance) { create(:service_day) }
    let(:attendance) { create(:attendance, service_day: service_day_with_attendance) }

    it 'returns absences only' do
      expect(described_class.absences).to include(absence)
      expect(described_class.absences).to include(covid_absence)
      expect(described_class.absences).not_to include(service_day_with_attendance)
    end

    it 'returns non-absences only' do
      expect(described_class.non_absences).not_to include(absence)
      expect(described_class.non_absences).not_to include(covid_absence)
      expect(described_class.non_absences).to include(service_day_with_attendance)
    end

    it 'returns standard absences only' do
      expect(described_class.standard_absences).to include(absence)
      expect(described_class.standard_absences).not_to include(covid_absence)
      expect(described_class.standard_absences).not_to include(service_day_with_attendance)
    end

    it 'returns covid absences only' do
      expect(described_class.covid_absences).not_to include(absence)
      expect(described_class.covid_absences).to include(covid_absence)
      expect(described_class.covid_absences).not_to include(service_day_with_attendance)
    end
  end

  context 'with date scopes' do
    let(:child) { create(:necc_child) }
    let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
    let(:child_approval) { child.child_approvals.first }
    let(:current_service_day) do
      create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).at_beginning_of_day
      )
    end
    let(:current_attendance) do
      create(:attendance, service_day: current_service_day, check_in: Time.current, child_approval: child_approval)
    end
    let(:past_attendance) do
      create(
        :attendance,
        service_day: create(
          :service_day,
          child: child,
          date: Time.new(2020, 12, 1, 9, 31, 0, timezone).at_beginning_of_day
        ),
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
          service_day: current_service_day,
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
    let!(:child) { create(:necc_child) }
    let!(:service_day) do
      create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).prev_occurring(:monday).at_beginning_of_day
      )
    end
    let!(:attendance) do
      create(:nebraska_hourly_attendance,
             service_day: service_day,
             check_in: service_day.date + 2.hours,
             check_out: nil,
             child_approval: child.child_approvals.first)
    end

    before do
      perform_enqueued_jobs
      service_day.reload
      child.reload
    end

    it 'calculates the right total when the service day is changed to an absence' do
      attendance.update!(check_out: attendance.check_in + 6.hours)
      service_day.update!(schedule: create(:schedule, weekday: service_day.date.wday, duration: 10.minutes))
      service_day.update!(absence_type: 'absence')
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(10.minutes)
    end

    it 'calculates the right total when the service day is changed to an absence_on_scheduled_day' do
      attendance.update!(check_out: attendance.check_in + 6.hours)
      service_day.update!(schedule: create(:schedule, weekday: service_day.date.wday, duration: 10.minutes))
      service_day.update!(absence_type: 'absence_on_scheduled_day')
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(10.minutes)
    end

    it 'calculates the right total when the service day is changed to an absence_on_unscheduled_day' do
      attendance.update!(check_out: attendance.check_in + 6.hours)
      service_day.update!(schedule: create(:schedule, weekday: service_day.date.wday, duration: 10.minutes))
      service_day.update!(absence_type: 'absence_on_unscheduled_day')
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(8.hours)
    end

    it 'calculates the right total when the service day is changed from an absence_on_scheduled_day' \
       'back to a non-absence' do
      attendance.update!(check_out: attendance.check_in + 6.hours)
      service_day.update!(schedule: create(:schedule, weekday: service_day.date.wday, duration: 10.minutes))
      service_day.update!(absence_type: 'absence_on_scheduled_day')
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(10.minutes)
      service_day.update!(absence_type: nil)
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(6.hours)
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
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(attendance.child.schedules.first.duration)
    end

    it 'for a single check-in with no check-out, returns 8 hours if day has no schedule' do
      child.schedules.destroy_all
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(8.hours)
    end

    it 'for multiple check-ins with and without check-outs, returns scheduled duration if total is less' do
      create(
        :attendance,
        service_day: service_day,
        child_approval: child.child_approvals.first,
        check_in: service_day.date + 1.hour + 30.minutes,
        check_out: service_day.date + 3.hours + 30.minutes
      )
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(child.schedules.first.duration)
    end

    it 'for multiple check-ins with and without check-outs, returns attended duration if total is more' do
      child = create(:necc_child)
      service_day = create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).at_beginning_of_day
      )
      create(
        :attendance,
        service_day: service_day,
        child_approval: attendance.child.child_approvals.first,
        check_in: attendance.check_in + 1.hour + 30.minutes,
        check_out: attendance.check_in + 10.hours + 30.minutes
      )
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.total_time_in_care).to eq(9.hours)
    end

    it 'with one or more check-ins, and none have a check-out, returns scheduled duration' do
      child = create(:necc_child)
      service_day = create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).at_beginning_of_day
      )
      create(
        :attendance,
        service_day: service_day,
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
      child = create(:necc_child)
      service_day = create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).at_beginning_of_day
      )
      create(:nebraska_hourly_attendance,
             service_day: service_day,
             check_in: service_day.date + 2.hours,
             child_approval: child.child_approvals.first)
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.tag_hourly_amount).to eq('5.5')
    end

    it 'returns correct hourly amount if integer' do
      child = create(:necc_child)
      service_day = create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).at_beginning_of_day
      )
      create(:nebraska_hour_attendance,
             service_day: service_day,
             check_in: service_day.date + 2.hours,
             child_approval: child.child_approvals.first)
      perform_enqueued_jobs
      service_day.reload
      expect(service_day.tag_hourly_amount).to eq('1')
    end
  end

  describe '#tag_daily_amount' do
    it 'returns correct daily amount' do
      child = create(:necc_child)
      service_day = create(
        :service_day,
        child: child,
        date: Time.current.in_time_zone(child.timezone).at_beginning_of_day
      )
      create(:nebraska_daily_attendance, service_day: service_day)
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
#  index_service_days_on_child_id           (child_id)
#  index_service_days_on_child_id_and_date  (child_id,date) UNIQUE
#  index_service_days_on_date               (date)
#  index_service_days_on_schedule_id        (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
