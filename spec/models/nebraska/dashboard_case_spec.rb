# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::DashboardCase do
  let(:child) { create(:necc_child) }
  let(:date) { Time.current.to_date }
  let(:child_approval) { child.child_approvals.first }
  let(:service_days) { child.service_days&.for_period(child_approval.effective_on, child_approval.expires_on) }

  describe '#family_fee' do
    before { child.reload }

    it 'returns the database value' do
      expect(described_class.new(
        child: child,
        filter_date: date,
        attended_days: service_days.non_absences,
        absent_days: service_days.absences
      ).family_fee)
        .to eq(child.active_nebraska_approval_amount(date).family_fee)
    end

    it 'returns the correct allocation of the family fee when there are two children' do
      # child object should have a default schedule, which is 40 hours a week, in whatever given month
      child_with_less_hours = create(
        :child,
        approvals: [child.approvals.first],
        schedules: [create(:schedule, weekday: 1)]
      )
      expect(described_class.new(
        child: child,
        filter_date: date,
        attended_days: service_days.non_absences,
        absent_days: service_days.absences
      ).family_fee)
        .to eq(child.active_nebraska_approval_amount(date).family_fee)
      expect(described_class.new(
        child: child_with_less_hours,
        filter_date: date,
        attended_days: service_days.non_absences,
        absent_days: service_days.absences
      ).family_fee).to eq(0)
    end
  end

  describe '#attended_weekly_hours' do
    it 'shows attended hours w/ weekly hours when the child_approval has weekly hours' do
      expect(described_class.new(
        child: child,
        filter_date: date,
        attended_days: service_days.non_absences,
        absent_days: service_days.absences
      ).attended_weekly_hours.to_i).to eq(
        child_approval.authorized_weekly_hours
      )
    end

    it 'shows attended hours w/o weekly hours when the child_approval has noweekly hours' do
      child_approval.update!(authorized_weekly_hours: nil)
      expect(described_class.new(
        child: child,
        filter_date: date,
        attended_days: service_days.non_absences,
        absent_days: service_days.absences
      ).attended_weekly_hours).to eq('0')
    end
  end

  describe '#absences_dates' do
    it 'Return all the absences of a child in the month' do
      test_date = Time.new(2023, 3, 6).utc
      Helpers.build_nebraska_absence_list(
        num: 2,
        date: test_date,
        child_approval: child.child_approvals.first
      )
      calculated_absences = described_class.new(
        child: child,
        filter_date: test_date,
        attended_days: child.service_days.non_absences,
        absent_days: child.service_days.absences
      ).absences_dates

      expect(child.service_days.absences).to eq(calculated_absences)
    end
  end
end
