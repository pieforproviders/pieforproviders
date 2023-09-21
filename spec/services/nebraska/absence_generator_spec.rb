# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::AbsenceGenerator, type: :service do
  let!(:child) { create(:necc_child) }
  let(:child_approval) { child.child_approvals.first }
  let(:attendance_date) do
    (
      child_approval
        .effective_on
        .at_end_of_month
        .in_time_zone(child.timezone) + 2.months + 3.weeks
    ).next_occurring(:monday)
  end

  let!(:state) do
    create(:state)
  end

  describe '#call' do
    before do
      travel_to attendance_date.in_time_zone(child.timezone)
      child.reload
    end

    after { travel_back }

    context 'when the child has an attendance on the date' do
      before do
        service_day = create(:service_day, child:)
        create(:attendance, service_day:, child_approval:, check_in: attendance_date)
        create(
          :state_time_rule,
          name: "Partial Day #{state.name}",
          state:,
          min_time: 60, # 1minute
          max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
        )
        create(
          :state_time_rule,
          name: "Full Day #{state.name}",
          state:,
          min_time: 5 * 3600, # 5 hours
          max_time: (10 * 3600) # 10 hours
        )
        create(
          :state_time_rule,
          name: "Full - Partial Day #{state.name}",
          state:,
          min_time: (10 * 3600) + 60, # 10 hours and 1 minute
          max_time: (24 * 3600)
        )
        perform_enqueued_jobs
        child.reload
      end

      it 'does not create an absence for that child' do
        expect { described_class.new(child:).call }.not_to change(ServiceDay, :count)
      end
    end

    context 'when the child does not have an attendance on that date' do
      it 'creates an absence if the child is scheduled for that day' do
        expect { described_class.new(child:).call }.to change(ServiceDay, :count).from(0).to(1)
      end

      it 'does not create an absence if the child is not scheduled for that day' do
        child.schedules.destroy_all
        create(:schedule, child:, weekday: attendance_date.wday + 1)
        child.reload
        expect { described_class.new(child:).call }.not_to change(ServiceDay, :count)
      end

      it 'creates an absence even if the child already has 5 absences this month' do
        Helpers.build_nebraska_absence_list(
          num: 5,
          date: attendance_date - 13.days,
          child_approval: child.child_approvals.first
        )
        expect { described_class.new(child:).call }.to change(ServiceDay, :count).from(5).to(6)
      end

      it 'creates an absence if the child has less than 5 absences this month' do
        Helpers.build_nebraska_absence_list(
          num: 2,
          date: attendance_date - 8.days,
          child_approval: child.child_approvals.first
        )
        expect { described_class.new(child:).call }.to change(ServiceDay, :count).from(2).to(3)
      end

      it 'creates an absence if the child has absences in the prior month but not the current one' do
        Helpers.build_nebraska_absence_list(
          num: 5,
          date: attendance_date - 1.month,
          child_approval: child.child_approvals.first
        )
        expect { described_class.new(child:).call }.to change(ServiceDay, :count).from(5).to(6)
      end

      it 'does not create an absence if the child has no active child approval for this date' do
        travel_to child.approvals.first.effective_on - 30.days
        expect { described_class.new(child:).call }.not_to change(ServiceDay, :count)
        travel_back
      end
    end
  end
end
