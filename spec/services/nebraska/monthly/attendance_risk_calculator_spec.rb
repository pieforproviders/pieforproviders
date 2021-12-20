# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Monthly::AttendanceRiskCalculator, type: :service do
  let!(:child) { create(:necc_child) }
  let!(:attendance_date) { Time.current.in_time_zone(child.timezone).at_beginning_of_month }

  before do
    child.reload
    create(:unaccredited_daily_ldds_rate, max_age: 216)
  end

  describe '#call' do
    it "returns not enough info if it's too early in the month" do
      travel_to attendance_date
      expect(described_class.new(
        child: child,
        filter_date: Time.current,
        estimated_revenue: 300,
        scheduled_revenue: 1000
      ).call).to eq('not_enough_info')
      travel_back
    end

    context "when it's late enough in the month to get results" do
      before do
        travel_to attendance_date + 12.days
      end

      after { travel_back }

      it 'returns at_risk when the ratio is less than -0.2' do
        expect(described_class.new(
          child: child,
          filter_date: Time.current,
          estimated_revenue: 300,
          scheduled_revenue: 1000
        ).call).to eq('at_risk')
      end

      it 'returns on_track when the ratio is between -0.2 and 0.2' do
        expect(described_class.new(
          child: child,
          filter_date: Time.current,
          estimated_revenue: 998,
          scheduled_revenue: 1000
        ).call).to eq('on_track')
      end

      it 'returns ahead_of_schedule when the ratio is above 0.2' do
        expect(described_class.new(
          child: child,
          filter_date: Time.current,
          estimated_revenue: 2200,
          scheduled_revenue: 1000
        ).call).to eq('ahead_of_schedule')
      end
    end
  end
end
