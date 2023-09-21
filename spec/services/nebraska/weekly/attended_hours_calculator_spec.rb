# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Weekly::AttendedHoursCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let(:first_attendance_date) do
    (child_approval.approval.effective_on.in_time_zone(child.timezone) + 1.month)
      .at_beginning_of_week(:sunday) + 2.days
  end
  let(:second_attendance_date) do
    (child_approval.approval.effective_on.in_time_zone(child.timezone) + 1.month)
      .at_beginning_of_week(:sunday) + 4.days
  end
  let(:check_in) { first_attendance_date.to_datetime + 8.hours + 21.minutes }
  let(:service_days) { child_approval.service_days }

  describe '#call' do
    before { child.reload }

    it 'with one attendance less than 6 hours, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (18 * 3600) # 18 hours
      )

      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 4.hours + 5.minutes)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(4.1)
    end

    it 'with one attendance more than 6 hours but less than 10 hours, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (18 * 3600) # 18 hours
      )
      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 6.hours + 15.minutes)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(6.3)
    end

    it 'with one attendance greater than 10 hours but less than 18 hours, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (18 * 3600) # 18 hours
      )
      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 12.hours + 42.minutes)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(12.7)
    end

    it 'with one attendance greater than 18 hours, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (rand(20..24) * 3600) # > 18 hours
      )
      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 19.hours + 11.minutes)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(19.2)
    end

    it 'with one attendance during the filter week and one before the filter week, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (18 * 3600) # 18 hours
      )
      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 12.hours + 42.minutes)
      saturday_service_day = create(:service_day, date: check_in.at_beginning_of_week(:sunday) - 1.day, child:)
      create(:attendance,
             service_day: saturday_service_day,
             child_approval:,
             check_in: check_in.at_beginning_of_week(:sunday) - 1.day + 8.hours,
             check_out: nil)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(12.7)
    end

    it 'with multiple attendances during the filter week, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (18 * 3600) # 18 hours
      )
      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 6.hours + 15.minutes)
      second_service_day = create(:service_day, date: check_in + 1.day, child:)
      create(:attendance,
             service_day: second_service_day,
             child_approval:,
             check_in: check_in + 1.day,
             check_out: check_in + 1.day + 12.hours + 42.minutes)
      third_service_day = create(:service_day, date: check_in + 2.days, child:)
      create(:attendance,
             service_day: third_service_day,
             child_approval:,
             check_in: check_in + 2.days,
             check_out: check_in + 2.days + 4.hours + 5.minutes)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(23.0)
    end

    it 'with an attendance during the filter week with multiple check-ins, returns the total' do
      state = create(:state)
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      )
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      )
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (18 * 3600) # 18 hours
      )
      service_day = create(:service_day, date: check_in, child:)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in:,
             check_out: check_in + 1.hour)
      create(:attendance,
             service_day:,
             child_approval:,
             check_in: check_in + 2.hours,
             check_out: check_in + 12.hours + 42.minutes)
      perform_enqueued_jobs
      service_days.each(&:reload)
      expect(
        described_class.new(
          filter_date: first_attendance_date,
          attendances: service_days.non_absences,
          absences: service_days.absences
        ).call
      ).to eq(11.7)
    end
  end
end
