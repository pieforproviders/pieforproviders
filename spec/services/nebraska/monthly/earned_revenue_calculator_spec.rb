# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Monthly::EarnedRevenueCalculator, type: :service do
  let!(:business) { create(:business, :nebraska_ldds, :unaccredited, :step_four) }
  let!(:child) { create(:necc_child, business: business) }
  let!(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
  let!(:attendance_date) { Time.new(2021, 7, 4, 0, 0, 0, timezone).to_date }
  let!(:full_day_rate) { create(:unaccredited_daily_ldds_rate, max_age: 216) }

  before do
    create(
      :nebraska_daily_attendance,
      check_in: attendance_date.at_beginning_of_day + 4.hours,
      child_approval: child.child_approvals.first
    )
    child.reload
  end

  describe '#call' do
    it 'calculates earned revenue for a signle attendance' do
      travel_to attendance_date.at_end_of_month
      expect(
        described_class.new(
          service_days: child.service_days,
          filter_date: Time.current
        ).call
      ).to eq(1 * full_day_rate.amount * business.ne_qris_bump)
      travel_back
    end
  end
end
