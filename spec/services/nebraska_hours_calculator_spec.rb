# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaHoursCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let(:first_attendance_date) { child_approval.effective_on.at_end_of_month + 2.days }
  let(:second_attendance_date) { child_approval.effective_on.at_end_of_month + 4.days }

  describe '#call' do
    context 'when calling with monthly scope' do
      let(:scoped_instance) { described_class.new(child: child, date: first_attendance_date, scope: :for_month) }

      it 'determines hours attended from the schedule when the attendance has no checkout' do
        child.reload
        child.schedules.destroy_all
        child.schedules << create(:schedule,
                                  effective_on: first_attendance_date - 3.months,
                                  weekday: first_attendance_date.wday,
                                  duration: 5.hours + 30.minutes)
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours + 21.minutes,
               check_out: nil)
        expect(scoped_instance.call).to eq(5.5)
      end

      it 'defaults to 8 hours, which will not count as hourly units, if they have no schedule & no checkout' do
        child.reload
        child.schedules.destroy_all
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours,
               check_out: nil)
        expect(scoped_instance.call).to eq(0)
      end

      it 'counts as hourly units by 15-min increments when less than 6 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 5.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(5.25)
      end

      it 'does not count as hourly units between 6 & 10 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 6.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(0)
      end

      it 'counts hourly units by 15-min increments that occur after the 10 hour mark' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 13.hours + 40.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(3.75)
      end

      it 'counts as 8 hourly units when the child has an attendance more than 18 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 18.hours + 27.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(scoped_instance.call).to eq(8.0)
      end

      it 'only returns the hourly units for the correct attendance with multiple attendances' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 5.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 8.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(scoped_instance.call).to eq(5.25)
      end

      it 'returns 0 when neither count for hourly attendance with multiple attendances' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 8.hours
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 8.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(scoped_instance.call).to eq(0)
      end

      it 'sums attendances when both count for hourly attendance with multiple attendances' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 5.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 10.hours + 22.minutes
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(scoped_instance.call).to eq(5.25 + 0.5)
      end
    end

    context 'when calling without scope' do
      before do
        check_in = child_approval.effective_on.at_beginning_of_day
        create(:attendance,
               child_approval: child_approval,
               check_in: check_in,
               check_out: check_in + 3.hours)
      end

      let(:unscoped_instance) { described_class.new(child: child, date: first_attendance_date, scope: nil) }

      it 'determines hours attended from the schedule when the attendance has no checkout' do
        child.reload
        child.schedules.destroy_all
        child.schedules << create(:schedule,
                                  effective_on: first_attendance_date - 3.months,
                                  weekday: first_attendance_date.wday,
                                  duration: 5.hours + 30.minutes)
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours + 21.minutes,
               check_out: nil)
        expect(unscoped_instance.call).to eq(5.5 + 3)
      end

      it 'defaults to 8 hours, which will not count as hourly units, if they have no schedule & no checkout' do
        child.reload
        child.schedules.destroy_all
        create(:attendance,
               child_approval: child_approval,
               check_in: first_attendance_date.to_datetime + 8.hours,
               check_out: nil)
        expect(unscoped_instance.call).to eq(0 + 3)
      end

      it 'counts as hourly units by 15-min increments when less than 6 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 5.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(5.25 + 3)
      end

      it 'does not count as hourly units between 6 & 10 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 6.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(0 + 3)
      end

      it 'counts hourly units by 15-min increments that occur after the 10 hour mark' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 13.hours + 40.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(3.75 + 3)
      end

      it 'counts as 8 hourly units when the child has an attendance more than 18 hours' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 18.hours + 27.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(unscoped_instance.call).to eq(8.0 + 3)
      end

      it 'only returns the hourly units for the correct attendance with multiple attendances' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 5.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 8.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(unscoped_instance.call).to eq(5.25 + 3)
      end

      it 'returns 0 when neither count for hourly attendance with multiple attendances' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 8.hours
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 8.hours
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(unscoped_instance.call).to eq(0 + 3)
      end

      it 'sums attendances when both count for hourly attendance with multiple attendances' do
        first_check_in = first_attendance_date.to_datetime + 8.hours
        first_check_out = first_check_in + 5.hours + 10.minutes
        second_check_in = second_attendance_date.to_datetime + 8.hours
        second_check_out = second_check_in + 10.hours + 22.minutes
        create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
        create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
        expect(unscoped_instance.call).to eq(5.25 + 0.5 + 3)
      end
    end
  end
end
