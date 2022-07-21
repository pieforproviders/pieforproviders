# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commands::ServiceDay::Update, type: :service do
  let(:child) { create(:child, :with_three_nebraska_attendances) }
  let(:service_day) { child.service_days.first }
  let(:active_schedule) { child.schedules.active_on(service_day.date).for_weekday(service_day.date.wday).first }

  describe '#initialize' do
    it 'initializes with required info' do
      expect do
        described_class.new(service_day: service_day, schedule: active_schedule, absence_type: nil)
      end.to not_raise_error
    end

    it 'throws an error when missing required info' do
      expect do
        described_class.new(schedule: active_schedule, absence_type: nil)
      end.to raise_error(ArgumentError)
    end

    it 'intializes with optional info' do
      expect do
        described_class.new(service_day: service_day, absence_type: nil)
      end.to not_raise_error
    end
  end

  describe '#update' do
    context 'when updating child with no active schedules' do
      before { child.schedules.destroy_all }

      it 'calls the ServiceDay Calculator and resets the service_day time in care' do
        service_day.attendances.destroy_all
        service_day.schedule.destroy
        described_class.new(service_day: service_day, schedule: active_schedule, absence_type: 'absence').update
        expect(service_day.total_time_in_care).to eq(8.hours)
      end
    end

    context 'when updating active service day to absence' do
      it 'sets the service_day\'s absence_type to absence_on_scheduled_day' do
        service_day.attendances.destroy_all
        described_class.new(service_day: service_day, schedule: active_schedule, absence_type: 'absence').update
        expect(service_day.absence_type).to eq('absence_on_scheduled_day')
      end
    end
  end
end
