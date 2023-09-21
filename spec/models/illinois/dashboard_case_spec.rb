# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::DashboardCase do
  let(:child) { create(:child) }
  let(:date) { Time.current }
  let(:child_approval) { child.child_approvals.first }
  let(:service_days) { child.service_days&.for_period(child_approval.effective_on, child_approval.expires_on) }

  describe '#guaranteed_revenue' do
    before { child.reload }

    it 'returns 0 since there are no attendances' do
      expect(described_class.new(
        child:,
        filter_date: date,
        attended_days: service_days.non_absences
      ).no_attendances)
        .to be_truthy
      expect(described_class.new(
        child:,
        filter_date: date,
        attended_days: service_days.non_absences
      ).guaranteed_revenue)
        .to eq(0)
    end

    it 'returns guaranteed revenue for business without quality rating' do
      create(:illinois_rate, age_bucket: 36, license_type: 'license_exempt_day_care_home', amount: 10.0)
      fcc_business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: nil)
      child_from_fcc = create(:child_in_illinois, business: fcc_business)
      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child: child_from_fcc)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child_from_fcc.active_child_approval(attendance_date)
      )

      perform_enqueued_jobs

      revenues = described_class.new(child: child_from_fcc, filter_date: Time.current)

      expected_revenue = Money.from_amount(10)

      expect(revenues.guaranteed_revenue).to eq(expected_revenue)
    end

    it 'returns guaranteed revenue for business with bronze quality rating' do
      create(:illinois_rate, age_bucket: 36, license_type: 'license_exempt_day_care_home', amount: 10.0)
      fcc_business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'bronze')
      child_from_fcc = create(:child_in_illinois, business: fcc_business)
      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child: child_from_fcc)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child_from_fcc.active_child_approval(attendance_date)
      )

      perform_enqueued_jobs

      revenues = described_class.new(child: child_from_fcc, filter_date: Time.current)

      expected_revenue = Money.from_amount(10)

      expect(revenues.guaranteed_revenue).to eq(expected_revenue)
    end

    it 'returns guaranteed revenue for business with silver quality rating' do
      create(:illinois_rate, age_bucket: 36, license_type: 'license_exempt_day_care_home', amount: 10.0)
      fcc_business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'silver')
      child_from_fcc = create(:child_in_illinois, business: fcc_business)
      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child: child_from_fcc)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child_from_fcc.active_child_approval(attendance_date)
      )

      perform_enqueued_jobs

      revenues = described_class.new(child: child_from_fcc, filter_date: Time.current)

      expected_revenue = Money.from_amount(11)

      expect(revenues.guaranteed_revenue).to eq(expected_revenue)
    end

    it 'returns guaranteed revenue for business with gold quality rating' do
      create(:illinois_rate, age_bucket: 36, license_type: 'license_exempt_day_care_home', amount: 10.0)
      fcc_business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'gold')
      child_from_fcc = create(:child_in_illinois, business: fcc_business)
      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child: child_from_fcc)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child_from_fcc.active_child_approval(attendance_date)
      )

      perform_enqueued_jobs

      revenues = described_class.new(child: child_from_fcc, filter_date: Time.current)

      expected_revenue = Money.from_amount(11.5)

      expect(revenues.guaranteed_revenue).to eq(expected_revenue)
    end

    it 'returns guaranteed revenue for special needs case' do
      create(:illinois_rate, age_bucket: 36, license_type: 'license_exempt_day_care_home')
      fcc_business = create(:business, license_type: 'license_exempt_day_care_home', quality_rating: 'silver')
      child_from_fcc = create(
        :child,
        business: fcc_business,
        approvals: [create(:approval, create_children: false, effective_on: Time.current.at_beginning_of_month)]
      )

      child_from_fcc.child_approvals.first.update!(
        special_needs_rate: true,
        special_needs_daily_rate: 70,
        special_needs_hourly_rate: 40
      )

      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child: child_from_fcc)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child_from_fcc.active_child_approval(attendance_date)
      )

      perform_enqueued_jobs

      revenues = described_class.new(child: child_from_fcc, filter_date: Time.current)

      expected_revenue = Money.from_amount(77)

      expect(revenues.guaranteed_revenue).to eq(expected_revenue)
    end
  end
end
