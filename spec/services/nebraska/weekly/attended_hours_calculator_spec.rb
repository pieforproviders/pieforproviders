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
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 4.hours + 5.minutes)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(4.1)
    end

    it 'with one attendance more than 6 hours but less than 10 hours, returns the total' do
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 6.hours + 15.minutes)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(6.3)
    end

    it 'with one attendance greater than 10 hours but less than 18 hours, returns the total' do
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 12.hours + 42.minutes)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(12.7)
    end

    it 'with one attendance greater than 18 hours, returns the total' do
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 19.hours + 11.minutes)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(19.2)
    end

    it 'with one attendance during the filter week and one before the filter week, returns the total' do
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 12.hours + 42.minutes)
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in.at_beginning_of_week(:sunday) - 1.day + 8.hours,
             check_out: nil)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(12.7)
    end

    it 'with multiple attendances during the filter week, returns the total' do
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 6.hours + 15.minutes)
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in + 1.day,
             check_out: check_in + 1.day + 12.hours + 42.minutes)
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in + 2.days,
             check_out: check_in + 2.days + 4.hours + 5.minutes)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(23.0)
    end

    it 'with an attendance during the filter week with multiple check-ins, returns the total' do
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in,
             check_out: check_in + 1.hour)
      create(:attendance,
             child_approval: child_approval,
             check_in: check_in + 2.hours,
             check_out: check_in + 12.hours + 42.minutes)
      expect(
        described_class.new(
          service_days: service_days,
          filter_date: first_attendance_date,
          schedules: child.schedules,
          child_approvals: child.child_approvals,
          rates: NebraskaRate.all
        ).call
      ).to eq(11.7)
    end
  end
end
