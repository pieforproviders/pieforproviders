# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::TagsCalculator, type: :service do
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
  let!(:child) { create(:necc_child) }
  let(:child_approval) { child.child_approvals.first }
  let(:attendance_date) do
    (
      child_approval
        .effective_on
        .at_end_of_month
        .in_time_zone(child.timezone) + 2.months + 3.weeks
    ).next_occurring(:monday)
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
      expect(described_class.new(service_day: service_day).send(:tag_hourly_amount)).to eq('5.5')
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
      expect(described_class.new(service_day: service_day).send(:tag_hourly_amount)).to eq('1')
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
      expect(described_class.new(service_day: service_day).send(:tag_daily_amount)).to eq('1')
    end
  end
end
