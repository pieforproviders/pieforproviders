# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildBlueprint do
  let(:child) { create(:child) }
  context 'returns the correct fields when no view option is passed' do
    it 'only includes the ID' do
      expect(JSON.parse(described_class.render(child)).keys).to contain_exactly('id', 'active', 'last_active_date', 'inactive_reason')
    end
  end
  context 'returns the correct fields when IL view is requested' do
    it 'includes IL dashboard fields' do
      expect(JSON.parse(described_class.render(child, view: :illinois_dashboard)).keys).to contain_exactly(
        'id',
        'active',
        'attendance_rate',
        'attendance_risk',
        'case_number',
        'full_name',
        'guaranteed_revenue',
        'max_approved_revenue',
        'potential_revenue',
        'last_active_date',
        'inactive_reason'
      )
    end
  end
  context 'returns the correct fields when NE view is requested' do
    let!(:child) { create(:necc_child) }
    let!(:child_approval) { child.child_approvals.first }
    let!(:attendance_date) { child_approval.approval.effective_on.at_end_of_month + 12.days }
    let!(:temporary_nebraska_dashboard_case) { create(:temporary_nebraska_dashboard_case, child: child, hours: 11) }

    before do
      create(:attendance,
             child_approval: child_approval,
             check_in: attendance_date.to_datetime + 3.hours,
             check_out: attendance_date.to_datetime + 6.hours)
    end

    it 'includes the child name and all cases' do
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date)).keys).to contain_exactly(
        'id',
        'active',
        'absences',
        'attendance_risk',
        'case_number',
        'earned_revenue',
        'estimated_revenue',
        'family_fee',
        'full_days',
        'full_name',
        'hours',
        'hours_attended',
        'last_active_date',
        'inactive_reason'
      )
    end
    it 'includes the correct information from the temporary dashboard case' do
      allow(Rails.application.config).to receive(:ff_live_algorithms).and_return('false')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['hours']).to eq('11.0')
    end
    context 'when using live algorithms' do
      it 'includes the child name and all cases' do
        allow(Rails.application.config).to receive(:ff_live_algorithms).and_return('true')
        expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['hours']).to eq('3.0')
        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 6.hours + 15.minutes)
        expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['hours']).to eq('6.25')
      end
    end
  end
end
