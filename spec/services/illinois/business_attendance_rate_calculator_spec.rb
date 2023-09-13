# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::BusinessAttendanceRateCalculator do
  before { travel_to '2022-11-01'.to_date }

  let(:business) { create(:business, active: true) }
  let(:child) { create(:child_in_illinois, businesses: [business]) }

  describe 'Checks methods for attendance rate IL calculator for businesses' do
    it 'check elegible attendances for an FCC' do
      november = Date.new(2022, 11, 1)
      business_attendance_rate_calculator = described_class.new(business, november)
      part_days_approved_per_week = child.illinois_approval_amounts.first.part_days_approved_per_week
      full_days_approved_per_week = child.illinois_approval_amounts.first.full_days_approved_per_week
      eligible_attendances = (part_days_approved_per_week + full_days_approved_per_week) * 5

      expect(eligible_attendances).to eq(business_attendance_rate_calculator.eligible_attendances)
    end

    it 'check elegible attendances for a Center' do
      november = Date.new(2022, 11, 1)
      center_business = create(:business, license_type: 'day_care_center')
      child_from_center = create(:child_in_illinois, business: center_business)
      business_attendance_rate_calculator = described_class.new(center_business, november)
      part_days_approved_per_week = child_from_center.illinois_approval_amounts.first.part_days_approved_per_week
      full_days_approved_per_week = child_from_center.illinois_approval_amounts.first.full_days_approved_per_week
      eligible_attendances = (part_days_approved_per_week + full_days_approved_per_week) * 5

      expect(eligible_attendances).to eq(business_attendance_rate_calculator.eligible_attendances)
    end

    it 'Checks attended days for children on an FCC' do
      november = Time.new(2022, 11, 1).utc
      business_attendance_rate_calculator = described_class.new(business, november)
      part_days_approved_per_week = child.illinois_approval_amounts.first.part_days_approved_per_week
      full_days_approved_per_week = child.illinois_approval_amounts.first.full_days_approved_per_week
      eligible_attendances = (part_days_approved_per_week + full_days_approved_per_week) * 5
      attended_days = child.attendance_rate(november) * eligible_attendances

      expect(business_attendance_rate_calculator.attended_days).to eq(attended_days)
    end

    it 'check attended days for children on a Center' do
      november = Time.new(2022, 11, 1).utc
      center_business = create(:business, license_type: 'day_care_center')
      child_from_center = create(:child_in_illinois, business: center_business)
      business_attendance_rate_calculator = described_class.new(center_business, november)
      part_days_approved_per_week = child_from_center.illinois_approval_amounts.first.part_days_approved_per_week
      full_days_approved_per_week = child_from_center.illinois_approval_amounts.first.full_days_approved_per_week
      eligible_attendances = (part_days_approved_per_week + full_days_approved_per_week) * 5
      attended_days = child.attendance_rate(november) * eligible_attendances

      expect(business_attendance_rate_calculator.attended_days).to eq(attended_days)
    end
  end
end
