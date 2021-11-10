# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::ServiceDayLimiter, type: :service do
  describe '#call' do
    let(:child) { create(:necc_child) }
    let(:child_approval) { child.child_approvals.first }
    let(:service_days) do
      child.reload
      child.service_days
    end
    let(:date) { Time.new(2021, 11, 0o1).in_time_zone(child.timezone).at_end_of_day }

    # TODO: how to write this factory?
    before { create(:absence_limit, :monthly, effective_on: date - 1.year, expires_on: nil) }

    context 'when checking against Absence Limits' do
      subject(:limiter) do
        described_class.new(service_days: service_days, limit_class: Nebraska::Absence, date: date).call
      end

      let(:attendances) { create_list(:nebraska_hourly_attendance, 5, child_approval: child_approval) }

      it 'returns the same list it was passed when there are less than the limit' do
        create(:nebraska_absence, child_approval: child_approval)
        expect(limiter).to eq(service_days)
      end

      it 'returns the limited list when there are more than the limit' do
        absences = create_list(:nebraska_absence, 6, child_approval: child_approval)
        expect(limiter).to eq(attendances + absences - absences.max_duration.first)
      end

      it "returns the limited list when there are absences in the list outside the limit's frequency" do
        absences = create_list(:nebraska_absence, 5, child_approval: child_approval)
        create(:nebraska_absence, child_approval: child_approval, check_in: attendances.first.check_in + 4.months)
        expect(limiter).to eq(attendances + absences)
      end
    end
  end
end
