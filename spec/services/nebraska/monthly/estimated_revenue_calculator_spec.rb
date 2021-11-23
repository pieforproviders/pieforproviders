# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Monthly::EstimatedRevenueCalculator, type: :service do
  let!(:business) { create(:business, :nebraska_ldds, :unaccredited, :step_four) }
  let!(:child) { create(:necc_child, business: business) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
  let!(:attendance_date) { Time.new(2021, 7, 4, 0, 0, 0, timezone).to_date }
  let!(:full_day_rate) { create(:unaccredited_daily_ldds_rate, max_age: 216) }

  before { child.reload }

  describe '#call' do
    it 'calculates remaining scheduled revenue for an entire month' do
      travel_to attendance_date.at_beginning_of_month
      expect(
        described_class.new(
          child: child,
          child_approval: child_approval,
          filter_date: Time.current
        ).call
      ).to eq(22 * full_day_rate.amount * business.ne_qris_bump)
      travel_back
    end
  end
end
