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
    let!(:approval) { create(:approval, create_children: false, effective_on: Time.zone.parse('July 1st, 2021'), expires_on: nil) }
    let!(:child) { create(:necc_child, approvals: [approval], effective_date: Time.zone.parse('July 1st, 2021')) }
    let!(:child_approval) { child.child_approvals.first }
    # Attendance Date is Aug 8, 2021
    let!(:attendance_date) { (child_approval.approval.effective_on.at_end_of_month + 12.days).at_beginning_of_week(:sunday) }
    let!(:temporary_nebraska_dashboard_case) do
      create(:temporary_nebraska_dashboard_case, child: child, hours: 11, full_days: 3, hours_attended: 12, family_fee: 120.50, earned_revenue: 175.60, estimated_revenue: 265.40,
                                                 attendance_risk: 'ahead_of_schedule')
    end

    before do
      child.business.update!(accredited: true, qris_rating: 'step_four')
      child_approval.update!(special_needs_rate: false)
      create(:nebraska_rate, :accredited, :hourly, :ldds, amount: 5.15, effective_on: Time.zone.parse('May 1st, 2021'), expires_on: nil)
      create(:nebraska_rate, :accredited, :daily, :ldds, amount: 25.15, effective_on: Time.zone.parse('May 1st, 2021'), expires_on: nil)
      create(:attendance,
             child_approval: child_approval,
             check_in: attendance_date.to_datetime + 3.hours,
             check_out: attendance_date.to_datetime + 6.hours)

      create(:attendance,
             child_approval: child_approval,
             check_in: attendance_date.to_datetime + 3.days + 3.hours,
             check_out: attendance_date.to_datetime + 3.days + 9.hours)
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
      allow(Rails.application.config).to receive(:ff_ne_live_algorithms).and_return(false)
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['hours']).to eq('11.0')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['full_days']).to eq('3')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['hours_attended']).to eq('12.0')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['family_fee']).to eq('120.50')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['earned_revenue']).to eq('175.60')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['estimated_revenue']).to eq('265.40')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['attendance_risk']).to eq('ahead_of_schedule')
    end
    context 'when using live algorithms' do
      before do
        travel_to attendance_date + 5.days # dashboard view date is August 13, 2021
        child.active_nebraska_approval_amount(attendance_date).update!(family_fee: '80.00')
      end
      let(:family_fee) { child.active_nebraska_approval_amount(attendance_date).family_fee }
      let(:earned_revenue) { ((6.25 * 5.15 * (1.05**1)) + (2 * 25.15 * (1.05**1))) - family_fee }
      let(:estimated_revenue) do
        # the child will by default have an 8-hour schedule Mon-Fri, all full-day attendances
        # after Aug 13th there are 3 Mon, 3 Tue, 2 Wed, 2 Thu, and 3 Fri (including the dashboard day), 13 more scheduled days
        earned_revenue + (13 * 25.15 * (1.05**1))
      end
      let(:attendance_risk) do
        # Aug 2021 has 5 Mon, 5 Tue, 4 Wed, 4 Thu and 4 Fri, 22 scheduled days
        # Scheduled Revenue = (22 * 25.15 * 1.05) = 580.97
        # Estimated Revenue = (((6.25 * 5.15 * 1.05) + (2 * 25.15 * 1.05)) - 80) + (13 * 25.15 * 1.05) = 349.91
        # (349.91 - 580.97) / 580.97 = -0.40
        'at_risk'
      end
      it 'includes the child name and all live attendance data' do
        allow(Rails.application.config).to receive(:ff_ne_live_algorithms).and_return(true)
        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.zone.now))

        expect(parsed_body['hours']).to eq('3.0')
        expect(parsed_body['family_fee']).to eq(format('%.2f', family_fee))
        expect(parsed_body['hours_attended']).to eq("9.0 of #{child_approval.authorized_weekly_hours}")

        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 2.days + 3.hours,
                            check_out: attendance_date.to_datetime + 2.days + 6.hours + 15.minutes)

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.zone.now))
        expect(parsed_body['hours']).to eq('6.25')
        expect(parsed_body['full_days']).to eq('1')
        expect(parsed_body['hours_attended']).to eq("12.3 of #{child_approval.authorized_weekly_hours}")
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', 0.0))

        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.zone.now))
        expect(parsed_body['full_days']).to eq('2')
        expect(parsed_body['hours_attended']).to eq("18.6 of #{child_approval.authorized_weekly_hours}")
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', earned_revenue))
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', estimated_revenue))
        expect(parsed_body['attendance_risk']).to eq(attendance_risk)

        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)
        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)
        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)
        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)
        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)
        create(:attendance, child_approval: child_approval, check_in: attendance_date.to_datetime + 1.day + 3.hours,
                            check_out: attendance_date.to_datetime + 1.day + 9.hours + 18.minutes)

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.zone.now))
        expect(parsed_body['attendance_risk']).to eq('on_track')
      end
    end
  end
end
