# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Monthly::AttendanceRiskCalculator, type: :service do
  let!(:business) { create(:business, :nebraska_ldds, :unaccredited, :step_four) }
  let!(:child) { create(:necc_child, business: business) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:attendance_date) { Time.current.in_time_zone(child.timezone).at_beginning_of_month }

  before do
    child.reload
    create(:unaccredited_daily_ldds_rate, max_age: 216)
  end

  describe '#call' do
    it "returns not enough info if it's too early in the month" do
      travel_to Time.current.in_time_zone(child.timezone).at_beginning_of_month
      expect(described_class.new(child: child,
                                 child_approval: child_approval,
                                 filter_date: Time.current).call).to eq('not_enough_info')
      travel_back
    end

    context "when it's late enough in the month to get results" do
      before do
        travel_to Time.current.in_time_zone(child.timezone).at_beginning_of_month + 12.days
      end

      after { travel_back }

      it 'returns at_risk with no attendances by the 12th' do
        expect(described_class.new(child: child,
                                   child_approval: child_approval,
                                   filter_date: Time.current).call).to eq('at_risk')
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when there are attendances' do
        before do
          create(:nebraska_daily_attendance, check_in: attendance_date + 2.hours)
          build_list(:attendance, 7) do |attendance|
            attendance.child_approval = child_approval
            attendance.check_in = Helpers.next_attendance_day(child_approval: child_approval) + 3.hours
            attendance.check_out = Helpers.next_attendance_day(child_approval: child_approval) + 9.hours + 18.minutes
            attendance.save!
          end
        end

        it 'returns on_track with 7 attendances by the 12th' do
          expect(described_class.new(child: child,
                                     child_approval: child_approval,
                                     filter_date: Time.current).call).to eq('on_track')
        end

        it 'returns ahead_of_schedule with 7 attendances by the 12th with a shorter schedule' do
          child.schedules.take(3).each(&:destroy)
          expect(described_class.new(child: child,
                                     child_approval: child_approval,
                                     filter_date: Time.current).call).to eq('ahead_of_schedule')
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
