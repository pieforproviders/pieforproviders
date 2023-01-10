# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::DashboardCase do
  let(:child) { create(:child) }
  let(:date) { Time.current.to_date }
  let(:child_approval) { child.child_approvals.first }
  let(:service_days) { child.service_days&.for_period(child_approval.effective_on, child_approval.expires_on) }

  describe '#guaranteed_revenue' do
    before { child.reload }

    it 'returns 0 since there are no attendances' do
      expect(described_class.new(
        child: child,
        filter_date: date,
        attended_days: service_days.non_absences
      ).no_attendances)
        .to be_truthy
      expect(described_class.new(
        child: child,
        filter_date: date,
        attended_days: service_days.non_absences
      ).guaranteed_revenue)
        .to eq(0)
    end

    it 'returns guaranteed revenue for business without quality rating' do
      fcc_business = create(:business, license_type: 'family_child_care_home_i', quality_rating: nil)
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

      earned_revenue = revenues.earned_revenue_below_threshold

      quality_bump = 1

      # binding.pry

      expect(revenues.guaranteed_revenue).to eq(earned_revenue * quality_bump)
    end

    it 'returns guaranteed revenue for business with bronze quality rating' do
      fcc_business = create(:business, license_type: 'family_child_care_home_i', quality_rating: 'bronze')
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

      earned_revenue = revenues.earned_revenue_below_threshold

      quality_bump = 1

      # binding.pry

      expect(revenues.guaranteed_revenue).to eq(earned_revenue * quality_bump)
    end

    it 'returns guaranteed revenue for business with silver quality rating' do
      fcc_business = create(:business, license_type: 'family_child_care_home_i', quality_rating: 'silver')
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

      earned_revenue = revenues.earned_revenue_below_threshold

      quality_bump = 1

      # binding.pry

      expect(revenues.guaranteed_revenue).to eq(earned_revenue * quality_bump)
    end

    it 'returns guaranteed revenue for business with gold quality rating' do
      fcc_business = create(:business, license_type: 'family_child_care_home_i', quality_rating: 'gold')
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

      earned_revenue = revenues.earned_revenue_below_threshold

      quality_bump = 1

      # binding.pry

      expect(revenues.guaranteed_revenue).to eq(earned_revenue * quality_bump)
    end
  end
end
