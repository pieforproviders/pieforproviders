# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Daily::HoursDurationCalculator, type: :service do
  let!(:state) do
    create(:state)
  end
  # rubocop:disable RSpec/LetSetup
  let!(:state_time_rules) do
    [
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state: state,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      ),
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state: state,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      ),
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state: state,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (24 * 3600)
      )
    ]
  end
  # rubocop:enable RSpec/LetSetup
  let!(:service_day) { create(:service_day, child: create(:necc_child)) }
  let!(:attendance) do
    create(:nebraska_hourly_attendance,
           service_day: service_day,
           child_approval: service_day.child.child_approvals.first)
  end

  describe '#call' do
    it 'returns hours for a service day with a single attendance in the hourly range' do
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(5.5)
    end

    it 'does not return hours for a service day with a single attendance in the daily range' do
      attendance.update!(check_out: attendance.check_in + 7.hours + 14.minutes)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(0)
    end

    it 'returns hours for a service day with a single attendance in the daily-plus-hourly range' do
      attendance.update!(check_out: attendance.check_in + 11.hours + 38.minutes)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(1.75)
    end

    it 'returns hours for a service day with a single attendance in the daily-plus-hourly-max range' do
      attendance.update!(check_out: attendance.check_in + 19.hours + 12.minutes)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(8)
    end

    it 'returns hours for a service day with multiple attendances in the hourly range' do
      attendance.update!(check_out: attendance.check_in + 1.hour + 7.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        service_day: service_day,
        check_in: attendance.check_in + 2.hours,
        check_out: attendance.check_in + 3.hours + 38.minutes
      )
      # total time in care is 2.hours + 45.minutes
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(2.75)
    end

    it 'does not return hours for a service day with multiple attendances in the daily range' do
      attendance.update!(check_out: attendance.check_in + 7.hours + 14.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        service_day: service_day,
        check_in: attendance.check_in + 8.hours,
        check_out: attendance.check_in + 9.hours + 6.minutes
      )
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(0)
    end

    it 'returns hours for a service day with multiple attendances in the daily-plus-hourly range' do
      attendance.update!(check_out: attendance.check_in + 11.hours + 38.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        service_day: service_day,
        check_in: attendance.check_in + 12.hours,
        check_out: attendance.check_in + 13.hours + 18.minutes
      )
      # total time in care is 12.hours + 56.minutes
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(3)
    end

    it 'returns hours for a service day with multiple attendances in the daily-plus-hourly-max range' do
      attendance.update!(check_out: attendance.check_in + 19.hours + 12.minutes)
      create(
        :nebraska_hourly_attendance,
        child_approval: attendance.child_approval,
        service_day: service_day,
        check_in: attendance.check_in + 20.hours,
        check_out: attendance.check_in + 21.hours + 31.minutes
      )
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(total_time_in_care: service_day.total_time_in_care).call).to eq(8)
    end
  end
end
