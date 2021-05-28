# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaHoursCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let(:first_attendance_date) { child_approval.approval.effective_on.at_end_of_month + 2.days }
  let(:second_attendance_date) { child_approval.approval.effective_on.at_end_of_month + 4.days }

  describe '#call' do
    context 'the child has an attendance with no checkout' do
      it 'does not count as hourly units' do
        create(:attendance, child_approval: child_approval, check_in: first_attendance_date.to_datetime + 8.hours, check_out: nil)
        expect(described_class.new(child, first_attendance_date).call).to eq(0)
      end
    end
    context 'the child has an attendance less than 6 hours' do
      it 'counts as hourly units by 15-min increments' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 5.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(described_class.new(child, first_attendance_date).call).to eq(5.25)
      end
    end
    context 'the child has an attendance more than 6 hours but less than 10 hours' do
      it 'does not count as hourly units' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 6.hours + 10.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(described_class.new(child, first_attendance_date).call).to eq(0)
      end
    end
    context 'the child has an attendance more than 10 hours but less than 866 minutes' do
      it 'counts only the as hourly units by 15-min increments that occur after the 10 hour mark' do
        check_in = first_attendance_date.to_datetime + 8.hours
        check_out = check_in + 13.hours + 40.minutes
        create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out)
        expect(described_class.new(child, first_attendance_date).call).to eq(3.75)
      end
    end
    context 'the child has multiple attendances' do
      context 'one counts for hourly units and the other does not' do
        it 'only returns the hourly units for the correct attendance' do
          first_check_in = first_attendance_date.to_datetime + 8.hours
          first_check_out = first_check_in + 5.hours + 10.minutes
          second_check_in = second_attendance_date.to_datetime + 8.hours
          create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
          create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: nil)
          expect(described_class.new(child, first_attendance_date).call).to eq(5.25)
        end
      end
      context 'neither count for hourly units' do
        it 'returns 0' do
          first_check_in = first_attendance_date.to_datetime + 8.hours
          second_check_in = second_attendance_date.to_datetime + 8.hours
          second_check_out = second_check_in + 8.hours
          create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: nil)
          create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
          expect(described_class.new(child, first_attendance_date).call).to eq(0)
        end
      end
      context 'both count for hourly units' do
        it 'sums them' do
          first_check_in = first_attendance_date.to_datetime + 8.hours
          first_check_out = first_check_in + 5.hours + 10.minutes
          second_check_in = second_attendance_date.to_datetime + 8.hours
          second_check_out = second_check_in + 10.hours + 22.minutes
          create(:attendance, child_approval: child_approval, check_in: first_check_in, check_out: first_check_out)
          create(:attendance, child_approval: child_approval, check_in: second_check_in, check_out: second_check_out)
          expect(described_class.new(child, first_attendance_date).call).to eq(5.25 + 0.25)
        end
      end
    end
  end
end
