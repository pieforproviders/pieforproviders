# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Daily::DaysDurationCalculator, type: :service do
  let!(:attendance) { create(:nebraska_daily_attendance) }
  let!(:service_day) { attendance.service_day }

  describe '#call' do
    it 'does not return days for a service day with a single attendance in the hourly range' do
      attendance.update!(check_out: attendance.check_in + 1.hour + 14.minutes)
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(0)
    end

    it 'returns days for a service day with a single attendance in the daily range' do
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1)
    end

    it 'returns days for a service day with a single attendance in the daily-plus-hourly range' do
      attendance.update!(check_out: attendance.check_in + 11.hours + 38.minutes)
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1)
    end

    it 'returns days for a service day with a single attendance in the daily-plus-hourly-max range' do
      attendance.update!(check_out: attendance.check_in + 19.hours + 12.minutes)
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1)
    end

    it 'does not return days for a service day with multiple attendances in the hourly range' do
      attendance.update!(check_out: attendance.check_in + 1.hour + 7.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        check_in: attendance.check_in + 2.hours,
        check_out: attendance.check_in + 3.hours + 38.minutes
      )
      # total time in care is 2.hours + 45.minutes
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(0)
    end

    it 'returns days for a service day with multiple attendances in the daily range' do
      attendance.update!(check_out: attendance.check_in + 7.hours + 14.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        check_in: attendance.check_in + 8.hours,
        check_out: attendance.check_in + 9.hours + 6.minutes
      )
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1)
    end

    it 'returns days for a service day with multiple attendances in the daily-plus-hourly range' do
      attendance.update!(check_out: attendance.check_in + 11.hours + 38.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        check_in: attendance.check_in + 12.hours,
        check_out: attendance.check_in + 13.hours + 18.minutes
      )
      # total time in care is 12.hours + 56.minutes
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1)
    end

    it 'returns days for a service day with multiple attendances in the daily-plus-hourly-max range' do
      attendance.update!(check_out: attendance.check_in + 19.hours + 12.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        check_in: attendance.check_in + 20.hours,
        check_out: attendance.check_in + 21.hours + 31.minutes
      )
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1)
    end
  end
end
