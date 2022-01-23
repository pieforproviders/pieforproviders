# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::DashboardCase, type: :model do
  let(:child) { create(:necc_child) }
  let(:date) { Time.current.to_date }

  describe '#family_fee' do
    before { child.reload }

    it 'returns the database value' do
      expect(described_class.new(
        child: child,
        filter_date: date,
        service_days: child.child_approvals.first.service_days
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
        service_days: child.child_approvals.first.service_days
      ).family_fee)
        .to eq(child.active_nebraska_approval_amount(date).family_fee)
      expect(described_class.new(
        child: child_with_less_hours,
        filter_date: date,
        service_days: child.child_approvals.first.service_days
      ).family_fee).to eq(0)
    end
  end
end
