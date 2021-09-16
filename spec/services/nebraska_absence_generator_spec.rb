# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NebraskaAbsenceGenerator, type: :service do
  let!(:child) { create(:necc_child) }
  let(:child_approval) { child.child_approvals.first }
  let(:attendance_date) { (child_approval.effective_on.at_end_of_month.in_time_zone(child.timezone) + 2.weeks).next_occurring(:monday) }

  describe '#call' do
    before do
      travel_to attendance_date.in_time_zone(child.timezone)
      child.reload
    end
    # rubocop:disable Rails/RedundantTravelBack
    after { travel_back }
    # rubocop:enable Rails/RedundantTravelBack
    context 'the child has an attendance on the date' do
      before do
        create(:attendance, child_approval: child_approval, check_in: attendance_date)
      end
      it 'does not create an absence for that child' do
        expect { described_class.new(child).call }.not_to change(Attendance, :count)
      end
    end

    context 'the child does not have an attendance on that date' do
      it 'creates an absence if the child is scheduled for that day' do
        expect { described_class.new(child).call }.to change { Attendance.count }.from(0).to(1)
      end

      it 'does not create an absence if the child is not scheduled for that day' do
        child.schedules.destroy_all
        create(:schedule, child: child, weekday: attendance_date.wday + 1)
        child.reload
        expect { described_class.new(child).call }.not_to change(Attendance, :count)
      end

      it 'creates an absence even if the child already has 5 absences this month' do
        create_list(:attendance, 5, child_approval: child_approval, check_in: attendance_date - 1.week, absence: 'absence')
        expect { described_class.new(child).call }.to change { Attendance.count }.from(5).to(6)
      end

      it 'creates an absence if the child has less than 5 absences this month' do
        create_list(:attendance, 2, child_approval: child_approval, check_in: attendance_date - 1.week, absence: 'absence')
        expect { described_class.new(child).call }.to change { Attendance.count }.from(2).to(3)
      end

      it 'creates an absence if the child has absences in the prior month but not the current one' do
        create_list(:attendance, 5, child_approval: child_approval, check_in: (attendance_date - 1.month).next_occurring(:monday), absence: 'absence')
        expect { described_class.new(child).call }.to change { Attendance.count }.from(5).to(6)
      end

      it 'does not create an absence if the child has no active child approval for this date' do
        travel_to child.approvals.first.effective_on - 30.days
        expect { described_class.new(child).call }.not_to change(Attendance, :count)
        travel_back
      end
    end
  end
end
