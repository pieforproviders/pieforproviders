# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaWeeklyHoursAttendedCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let(:first_attendance_date) { (child_approval.approval.effective_on.at_end_of_month).at_beginning_of_week(:sunday) + 2.days }
  let(:second_attendance_date) { (child_approval.approval.effective_on.at_end_of_month).at_beginning_of_week(:sunday) + 4.days }
  let(:check_in) { first_attendance_date.to_datetime + 8.hours + 21.minutes }

  describe '#call' do
    context 'with one attendance less than 6 hours' do
      it 'returns the total attended hours of authorized weekly hours as a string' do
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_in + 4.hours + 5.minutes)
        expect(described_class.new(child, first_attendance_date).call).to eq("4.1 of #{child_approval.authorized_weekly_hours}")
      end
    end
    context 'with one attendance more than 6 hours but less than 10 hours' do
      it 'returns the total attended hours of authorized weekly hours as a string' do
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_in + 6.hours + 15.minutes)
        expect(described_class.new(child, first_attendance_date).call).to eq("6.3 of #{child_approval.authorized_weekly_hours}")
      end
    end
    context 'with one attendance greater than 10 hours but less than 18 hours' do
      it 'returns the total attended hours of authorized weekly hours as a string' do
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_in + 12.hours + 42.minutes)
        expect(described_class.new(child, first_attendance_date).call).to eq("12.7 of #{child_approval.authorized_weekly_hours}")
      end
    end
    context 'with one attendance greater than 18 hours' do
      it 'returns the total attended hours of authorized weekly hours as a string' do
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_in + 19.hours + 11.minutes)
        expect(described_class.new(child, first_attendance_date).call).to eq("19.2 of #{child_approval.authorized_weekly_hours}")
      end
    end
    context 'with one attendance during the filter week and one before the filter week' do
      it 'returns the total attended hours of authorized weekly hours as a string' do
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_in + 12.hours + 42.minutes)
        create(:attendance, child_approval: child_approval, check_in: check_in.at_beginning_of_week(:sunday) - 1.day + 8.hours, check_out: nil)
        expect(described_class.new(child, first_attendance_date).call).to eq("12.7 of #{child_approval.authorized_weekly_hours}")
      end
    end
    context 'with multiple attendances during the filter week' do
      it 'returns the total attended hours of authorized weekly hours as a string' do
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_in + 6.hours + 15.minutes)
        create(:attendance, child_approval: child_approval, check_in: check_in + 1.day, check_out: check_in + 1.day + 12.hours + 42.minutes)
        create(:attendance, child_approval: child_approval, check_in: check_in + 2.days, check_out: check_in + 2.days + 4.hours + 5.minutes)
        expect(described_class.new(child, first_attendance_date).call).to eq("23.0 of #{child_approval.authorized_weekly_hours}")
      end
    end
  end
end
