# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Monthly::AttendanceRiskCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:attendance_date) { Time.current.in_time_zone(child.timezone).at_beginning_of_month }

  describe '#call' do
    it "returns not enough info if it's too early in the month" do
      travel_to Time.current.in_time_zone(child.timezone).at_beginning_of_month
      expect(described_class.new(
        child: child,
        child_approval: child_approval,
        filter_date: Time.current,
        estimated_revenue: 300,
        scheduled_revenue: 1000
      ).call).to eq('not_enough_info')
      travel_back
    end

    context "when it's late enough in the month to get results" do
      before do
        travel_to Time.current.in_time_zone(child.timezone).at_beginning_of_month + 12.days
      end

      after { travel_back }

      it 'returns at_risk when the ratio is below -0.2' do
        expect(described_class.new(
          child: child,
          child_approval: child_approval,
          filter_date: Time.current,
          estimated_revenue: 300,
          scheduled_revenue: 1000
        ).call).to eq('at_risk')
      end

      it 'returns on_track when the ratio is between -0.2 and 0.2' do
        expect(described_class.new(
          child: child,
          child_approval: child_approval,
          filter_date: Time.current,
          estimated_revenue: 990,
          scheduled_revenue: 1000
        ).call).to eq('on_track')
      end

      it 'returns ahead_of_schedule when the ratio is above 0.2' do
        expect(described_class.new(
          child: child,
          child_approval: child_approval,
          filter_date: Time.current,
          estimated_revenue: 1300,
          scheduled_revenue: 1000
        ).call).to eq('ahead_of_schedule')
      end
    end
  end
end
