# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commands::Attendance::Update, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:check_in) { Time.parse('9:00am').utc.prev_occurring(:monday) }
  let!(:check_out) { Time.parse('10:50am').utc.prev_occurring(:monday) }
  let!(:attendance) { create(:attendance, child_approval: child_approval, check_in: check_in, check_out: check_out) }
  let!(:state) do
    create(:state)
  end
  # rubocop:disable RSpec/LetSetup
  let!(:state_time_rules) do
    [
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state: state,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      ),
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state: state,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      ),
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state: state,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (26 * 3600)
      )
    ]
  end
  # rubocop:enable RSpec/LetSetup

  describe '#initialize' do
    it 'initializes with required info' do
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_in + 6.hours,
          absence_type: 'absence'
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

  describe '#update' do
    it 'does nothing if all the data is the same' do
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_out,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)

      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day.absence_type).to be_nil
      # TODO: And not call the update methods?
    end

    it 'does nothing if all the data is the same including the service_day absence_type' do
      attendance.service_day.update!(absence_type: 'absence')
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_out,
          absence_type: 'absence'
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)

      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day.absence_type).to eq('absence_on_scheduled_day')
      # TODO: And not call the update methods?
    end

    it 'updates the attendance if the check_in has changed to the same day' do
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in + 10.minutes,
          check_out: check_out,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)

      expect(attendance.check_in).to eq(check_in + 10.minutes)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day.absence_type).to be_nil
    end

    it 'updates the attendance if the check_out has changed to the same day' do
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_out + 20.minutes,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)

      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out + 20.minutes)
      expect(attendance.service_day.absence_type).to be_nil
    end

    it 'updates the service_day if the absence_type has changed' do
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_out,
          absence_type: 'covid_absence'
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
        .and not_change(attendance, :check_out)

      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day.absence_type).to eq('covid_absence')
      # TODO: eventually - change this to expect Commands::ServiceDay::Update to have been called
    end

    it 'changes the service_day if the check_in has changed to a different day' do
      service_day = attendance.service_day
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in + 10.minutes - 1.day,
          check_out: check_out,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)

      expect(attendance.check_in).to eq(check_in + 10.minutes - 1.day)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day).not_to eq(service_day)
      expect(attendance.service_day.absence_type).to be_nil
    end

    it 'does not change the service_day if the check_out has changed to a different day' do
      service_day = attendance.service_day
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_out + 1.day,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out + 1.day)
      expect(attendance.service_day).to eq(service_day)
      expect(attendance.service_day.absence_type).to be_nil
    end

    it 'raises an error when changing the attendance to a day when the child has no child approval' do
      service_day = attendance.service_day
      expect do
        described_class.new(
          attendance: attendance,
          check_in: attendance.child_approval.effective_on.at_beginning_of_month - 3.days,
          check_out: attendance.child_approval.effective_on.at_beginning_of_month - 3.days + 6.hours,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
        .and raise_error(ActiveRecord::RecordInvalid)

      attendance.reload
      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day).to eq(service_day)
      expect(attendance.service_day.absence_type).to be_nil
    end

    it 'raises an error when the check out is before the check in' do
      service_day = attendance.service_day
      expect do
        described_class.new(
          attendance: attendance,
          check_in: check_in,
          check_out: check_in - 6.hours,
          absence_type: nil
        ).update
      end
        .to not_change(Attendance, :count)
        .and not_change(ServiceDay, :count)
        .and raise_error(ActiveRecord::RecordInvalid)

      attendance.reload
      expect(attendance.check_in).to eq(check_in)
      expect(attendance.check_out).to eq(check_out)
      expect(attendance.service_day).to eq(service_day)
      expect(attendance.service_day.absence_type).to be_nil
    end

    it 'changes the schedule when changing to a different day if one is present for that weekday' do
      schedule = attendance.service_day.schedule
      described_class.new(
        attendance: attendance,
        check_in: check_in.next_occurring(:tuesday) + 1.day,
        check_out: check_out.next_occurring(:tuesday) + 1.day,
        absence_type: nil
      ).update

      attendance.reload
      expect(attendance.service_day.schedule).not_to eq(schedule)
      expect(attendance.service_day.schedule).to be_present
    end

    it 'removes the schedule when changing to a different day if one is not present for that weekday' do
      schedule = attendance.service_day.schedule
      described_class.new(
        attendance: attendance,
        check_in: check_in.next_occurring(:saturday),
        check_out: check_out.next_occurring(:saturday),
        absence_type: nil
      ).update

      attendance.reload
      expect(attendance.service_day.schedule).not_to eq(schedule)
      expect(attendance.service_day.schedule).to be_nil
    end

    it 'recalculates the time in care for the service day when check_in changes' do
      # TODO: I'm fairly certain this is the ServiceDayCalculatorJob + the ServiceDayScheduleUpdaterJob
      # which should be refactored to not be jobs; we'll want to wrap larger implementations in jobs, rather
      # than individual model callbacks
      # This test (and the next two) WILL NOT PASS unless the next three lines exist in this exact order
      # So.........that's weird and I'd like to be rid of it.
      perform_enqueued_jobs
      attendance.reload
      perform_enqueued_jobs

      expect(attendance.service_day.total_time_in_care).to eq(1.hour + 50.minutes)
      described_class.new(
        attendance: attendance,
        check_in: check_in - 1.hour,
        check_out: check_out,
        absence_type: nil
      ).update
      expect(attendance.service_day.total_time_in_care).to eq(2.hours + 50.minutes)
    end

    it 'recalculates the time in care for the service day when check_out changes' do
      perform_enqueued_jobs
      attendance.reload
      perform_enqueued_jobs

      expect(attendance.service_day.total_time_in_care).to eq(1.hour + 50.minutes)
      described_class.new(
        attendance: attendance,
        check_in: check_in,
        check_out: check_in + 6.hours,
        absence_type: nil
      ).update
      expect(attendance.service_day.total_time_in_care).to eq(6.hours)
    end

    it 'recalculates the time in care for the service day when absence_type changes' do
      perform_enqueued_jobs
      attendance.reload
      perform_enqueued_jobs

      expect(attendance.service_day.total_time_in_care).to eq(1.hour + 50.minutes)
      described_class.new(
        attendance: attendance,
        check_in: check_in,
        check_out: check_out,
        absence_type: 'absence'
      ).update
      expect(attendance.service_day.total_time_in_care).to eq(8.hours)
    end
  end
end
