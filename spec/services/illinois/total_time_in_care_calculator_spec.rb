# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::TotalTimeInCareCalculator do
  let(:il_business) { create(:business) }
  let(:child) { create(:child_in_illinois, business: il_business) }
  let(:attendance_with_missing_checkout) { create(:attendance, check_in: Time.current, check_out: nil) }
  let(:valid_attendance) do
    create(:attendance,
           check_in: Time.current.at_beginning_of_day,
           check_out: Time.current.at_beginning_of_day + 3.hours)
  end
  let(:attendance_1ft_and_1pt) do
    create(:attendance,
           check_in: Time.current.at_beginning_of_day,
           check_out: Time.current.at_beginning_of_day + 16.hours)
  end
  let(:service_day) { create(:service_day, schedule: nil, child:) }

  describe '#call' do
    context 'when child has no attendances' do
      it 'doesn\'t flag the service day and does not change the total hours' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(0)
        expect(service_day.part_time).to eq(0)
        expect(service_day.full_time).to eq(0)
        expect(service_day.missing_checkout).to be(false)
      end
    end

    context 'when child has one attendance with a missing checkout' do
      before do
        service_day.attendances << attendance_with_missing_checkout
      end

      it 'flags the service day and does not change the total hours' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(0)
        expect(service_day.part_time).to eq(1) # part_days_approved_per_week > full_days_approved_per_week
        expect(service_day.full_time).to eq(0)
        expect(service_day.missing_checkout).to be(true)
      end
    end

    context 'when child has one valid attendance' do
      before do
        service_day.attendances << valid_attendance
      end

      it 'updates the total_time_in_care normally' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(3.hours)
        expect(service_day.part_time).to eq(1)
        expect(service_day.full_time).to eq(0)
        expect(service_day.missing_checkout).to be(false)
      end
    end

    context 'when child has a valid attendance and an attendance with a missing checkout' do
      before do
        service_day.attendances << valid_attendance
        service_day.attendances << attendance_with_missing_checkout
      end

      it 'updates the total_time_in_care and flags the service day' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(3.hours)
        expect(service_day.part_time).to eq(1)
        expect(service_day.full_time).to eq(0)
        expect(service_day.missing_checkout).to be(true)
      end
    end

    context 'when child has a valid 16 hours attendance' do
      before do
        service_day.attendances << attendance_1ft_and_1pt
      end

      it 'updates full and part times' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(16.hours)
        expect(service_day.full_time).to eq(1)
        expect(service_day.part_time).to eq(1)
      end
    end

    context 'when child has a valid 4 hours attendance' do
      before do
        part_time_attendance = create(
          :attendance,
          check_in: Time.current.at_beginning_of_day,
          check_out: Time.current.at_beginning_of_day + 3.hours
        )

        service_day.attendances << part_time_attendance
      end

      it 'updates full and part times' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(3.hours)
        expect(service_day.full_time).to eq(0)
        expect(service_day.part_time).to eq(1)
      end
    end

    context 'when child has a valid 18 hours attendance' do
      before do
        part_time_attendance = create(
          :attendance,
          check_in: Time.current.at_beginning_of_day,
          check_out: Time.current.at_beginning_of_day + 18.hours
        )

        service_day.attendances << part_time_attendance
      end

      it 'updates full and part times' do
        described_class.new(service_day:).call
        expect(service_day.total_time_in_care).to eq(18.hours)
        expect(service_day.full_time).to eq(2)
        expect(service_day.part_time).to eq(0)
      end
    end
  end
end
