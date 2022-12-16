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
  end
end
