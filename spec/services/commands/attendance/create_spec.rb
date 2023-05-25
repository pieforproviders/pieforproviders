# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commands::Attendance::Create, type: :service do
  let(:child) { create(:necc_child) }
  let(:child_approval) { child.child_approvals.first }
  let(:check_in) { Time.parse('9:00am').prev_occurring(:monday) }

  describe '#initialize' do
    it 'initializes with required info' do
      expect do
        described_class.new(check_in: check_in, child_id: child.id)
      end.to not_raise_error
    end

    it 'initializes with optional info' do
      expect do
        described_class.new(
          check_in: check_in,
          check_out: check_in + 6.hours,
          child_id: child.id,
          wonderschool_id: 'string'
        )
      end.to not_raise_error
    end

    it 'throws an argument error when missing required info' do
      expect do
        described_class.new(
          check_out: check_in + 6.hours
        )
      end.to raise_error(ArgumentError)
    end
  end

  describe '#create' do
    it 'creates the attendance on a new ServiceDay' do
      expect do
        described_class.new(
          check_in: check_in,
          check_out: check_in + 6.hours,
          child_id: child.id
        ).create
      end
        .to change(Attendance, :count).from(0).to(1)
        .and change(ServiceDay, :count).from(0).to(1)
    end

    it 'creates the attendance on an existing absent ServiceDay' do
      service_day = create(
        :service_day,
        child: child,
        date: check_in.strftime('%Y-%m-%d %H:%M:%S').to_datetime.at_beginning_of_day,
        absence_type: 'absence'
      )
      expect do
        described_class.new(
          check_in: check_in + 8.hours,
          check_out: check_in + 10.hours + 12.minutes,
          child_id: child.id
        ).create
        service_day.reload
      end
        .to change(Attendance, :count).from(0).to(1)
        .and not_change(ServiceDay, :count)
      expect(service_day.absence_type).to be_nil
    end

    it 'creates the attendance on an existing attended ServiceDay' do
      service_day = create(
        :service_day,
        child: child,
        date: check_in.strftime('%Y-%m-%d %H:%M:%S').to_datetime.at_beginning_of_day
      )
      create(:attendance, check_in: check_in, check_out: check_in + 6.hours, service_day: service_day)
      expect do
        described_class.new(
          check_in: check_in + 8.hours,
          check_out: check_in + 10.hours + 12.minutes,
          child_id: child.id
        ).create
      end
        .to change(Attendance, :count).from(1).to(2)
                                      .and not_change(ServiceDay, :count)
    end

    it 'raises an error when there is no matching child' do
      expect do
        described_class.new(
          check_in: check_in,
          check_out: check_in + 6.hours,
          child_id: 'bad-id'
        ).create
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
        .and raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error when there is no current child approval' do
      expect do
        described_class.new(
          check_in: child_approval.effective_on - 3.days,
          check_out: child_approval.effective_on - 3.days + 6.hours,
          child_id: child.id
        ).create
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
        .and raise_error(ActiveRecord::RecordInvalid)
    end

    it 'raises an error when the check out is before the check in' do
      expect do
        described_class.new(
          check_in: check_in,
          check_out: check_in - 6.hours,
          child_id: child.id
        ).create
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
        .and raise_error(ActiveRecord::RecordInvalid)
    end

    it 'assigns a schedule when one is present for that weekday' do
      described_class.new(
        check_in: check_in,
        check_out: check_in + 6.hours,
        child_id: child.id
      ).create
      expect(ServiceDay.first.schedule).to be_present
    end

    it 'does not assign a schedule when one is not present for that weekday' do
      described_class.new(
        check_in: check_in.prev_occurring(:saturday),
        check_out: check_in.prev_occurring(:saturday) + 6.hours,
        child_id: child.id
      ).create
      expect(ServiceDay.first.schedule).to be_nil
    end

    it 'calculates the time in care for the service day' do
      described_class.new(
        check_in: check_in.prev_occurring(:saturday),
        check_out: check_in.prev_occurring(:saturday) + 6.hours,
        child_id: child.id
      ).create
      expect(ServiceDay.first.total_time_in_care).to eq(6.hours)
    end
  end
end
