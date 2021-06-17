# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaFullDaysCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let(:first_attendance_date) { child_approval.approval.effective_on.at_end_of_month + 2.days }
  let(:second_attendance_date) { child_approval.approval.effective_on.at_end_of_month + 4.days }

  describe '#call' do
    context 'the child has an attendance with no checkout' do
      it 'determines full days attended from the schedule' do
        child.schedules.destroy_all
        child.schedules << create(:schedule,
                                  effective_on: first_attendance_date - 3.months,
                                  weekday: first_attendance_date.wday,
                                  start_time: first_attendance_date.to_datetime + 8.hours,
                                  end_time: first_attendance_date.to_datetime + 15.hours)
        create(:attendance, child_approval: child_approval, check_in: first_attendance_date.to_datetime + 8.hours + 21.minutes, check_out: nil)
        expect(described_class.new(child, first_attendance_date).call).to eq(1)
      end
      it 'defaults to 8 hours, which will count as full day units, if they have no schedule' do
        child.schedules.destroy_all
        create(:attendance, child_approval: child_approval, check_in: first_attendance_date.to_datetime + 8.hours, check_out: nil)
        expect(described_class.new(child, first_attendance_date).call).to eq(1)
      end
    end
    context 'the child has an attendance less than 6 hours' do
      it 'will not count as a full day' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 5.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(described_class.new(child, first_attendance_date).call).to eq(0)
      end
    end
    context 'the child has an attendance more than 6 hours but less than 10 hours' do
      it 'counts as a full day' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 6.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(described_class.new(child, first_attendance_date).call).to eq(1)
      end
    end
    context 'the child has an attendance more than 10 hours but less than 866 minutes' do
      it 'counts as a full day + hours (handled by the other calculator)' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 13.hours + 40.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(described_class.new(child, first_attendance_date).call).to eq(1)
      end
    end
    context 'the child has multiple attendances' do
      context 'one counts for full day units and the other does not' do
        it 'only returns the full day units for the correct attendance' do
          first_check_in = first_attendance_date.to_datetime + 8.hours
          first_check_out = first_check_in + 5.hours + 10.minutes
          second_check_in = second_attendance_date.to_datetime + 8.hours
          second_check_out = second_check_in + 7.hours
          create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
          create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
          expect(described_class.new(child, first_attendance_date).call).to eq(1)
        end
      end
      context 'neither count for full day units' do
        it 'returns 0' do
          first_check_in = first_attendance_date.to_datetime + 8.hours
          first_check_out = first_check_in + 4.hours
          second_check_in = second_attendance_date.to_datetime + 8.hours
          second_check_out = second_check_in + 3.hours
          create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
          create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
          expect(described_class.new(child, first_attendance_date).call).to eq(0)
        end
      end
      context 'both count for full day units' do
        it 'sums them' do
          first_check_in = first_attendance_date.to_datetime + 8.hours
          first_check_out = first_check_in + 8.hours + 10.minutes
          second_check_in = second_attendance_date.to_datetime + 8.hours
          second_check_out = second_check_in + 6.hours + 22.minutes
          create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
          create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
          expect(described_class.new(child, first_attendance_date).call).to eq(2)
        end
      end
    end
  end
end
