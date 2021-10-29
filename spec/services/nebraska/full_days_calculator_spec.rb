# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::FullDaysCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let(:first_attendance_date) { child_approval.approval.effective_on.at_end_of_month + 2.days }
  let(:second_attendance_date) { child_approval.approval.effective_on.at_end_of_month + 4.days }

  describe '#call' do
    context 'when sent with monthly scope' do
      let(:scoped_instance) { described_class.new(child: child, date: first_attendance_date, scope: :for_month) }

      it 'determines full days attended from the schedule when the attendance has no checkout' do
        child.schedules.destroy_all
        child.schedules << create(:schedule,
                                  effective_on: first_attendance_date - 3.months,
                                  weekday: first_attendance_date.wday,
                                  duration: 7.hours)
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours + 21.minutes,
               check_out: nil)
        expect(scoped_instance.call).to eq(1)
      end

      it 'defaults to 8 hours, which will count as full day units, if they have no schedule & no checkout' do
        child.schedules.destroy_all
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours,
               check_out: nil)
        expect(scoped_instance.call).to eq(1)
      end

      it 'will not count as a full day if the attendance is less than 6 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 5.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(0)
      end

      it 'counts as a full day when the child has an attendance between 6 & 10 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 6.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(1)
      end

      it 'counts as a full day + hours (handled by the other calculator) between 10 & 18 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 13.hours + 40.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(1)
      end

      it 'only returns the full day units for the correct attendance' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 5.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 7.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(scoped_instance.call).to eq(1)
      end

      it 'returns 0 when neither count for full day units' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 4.hours
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 3.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(scoped_instance.call).to eq(0)
      end

      it 'sums the attendances when both count for full day units' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 8.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 6.hours + 22.minutes
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(scoped_instance.call).to eq(2)
      end
    end

    context 'when sent without a scope' do
      let(:unscoped_instance) { described_class.new(child: child, date: first_attendance_date, scope: nil) }

      before do
        check_in = child_approval.effective_on.at_beginning_of_day
        create(:attendance,
               child_approval: child_approval,
               check_in: check_in,
               check_out: check_in + 6.hours)
      end

      it 'determines full days attended from the schedule when the attendance has no checkout' do
        child.schedules.destroy_all
        child.schedules << create(:schedule,
                                  effective_on: first_attendance_date - 3.months,
                                  weekday: first_attendance_date.wday,
                                  duration: 7.hours)
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours + 21.minutes,
               check_out: nil)
        expect(unscoped_instance.call).to eq(1 + 1)
      end

      it 'defaults to 8 hours, which will count as full day units, if they have no schedule & no checkout' do
        child.schedules.destroy_all
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours,
               check_out: nil)
        expect(unscoped_instance.call).to eq(1 + 1)
      end

      it 'will not count as a full day if the attendance is less than 6 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 5.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(0 + 1)
      end

      it 'counts as a full day when the child has an attendance between 6 & 10 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 6.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(1 + 1)
      end

      it 'counts as a full day + hours (handled by the other calculator) between 10 & 18 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 13.hours + 40.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(1 + 1)
      end

      it 'only returns the full day units for the correct attendance' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 5.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 7.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(unscoped_instance.call).to eq(1 + 1)
      end

      it 'returns 0 when neither count for full day units' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 4.hours
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 3.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(unscoped_instance.call).to eq(0 + 1)
      end

      it 'sums the attendances when both count for full day units' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 8.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 6.hours + 22.minutes
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(unscoped_instance.call).to eq(2 + 1)
      end
    end
  end
end
