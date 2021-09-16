# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildBlueprint do
  let(:child) { create(:child) }
  context 'returns the correct fields when no view option is passed' do
    it 'includes the ID, full name, and active info' do
      expect(JSON.parse(described_class.render(child)).keys).to contain_exactly('id', 'active', 'full_name', 'last_active_date', 'inactive_reason')
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
    let!(:approval) { create(:approval, create_children: false, effective_on: Time.zone.parse('June 1st, 2021'), expires_on: nil) }
    let!(:child) { create(:necc_child, approvals: [approval], effective_date: Time.zone.parse('June 1st, 2021')) }
    let!(:child_approval) { child.child_approvals.first }
    # Attendance Date is Jul 4th, 2021
    let!(:attendance_date) { (child_approval.approval.effective_on.in_time_zone(child.timezone).at_end_of_month + 5.days).at_beginning_of_week(:sunday) }
    let!(:temporary_nebraska_dashboard_case) do
      create(:temporary_nebraska_dashboard_case, child: child, hours: 11, full_days: 3, hours_attended: 12, family_fee: 120.50, earned_revenue: 175.60, estimated_revenue: 265.40,
                                                 attendance_risk: 'ahead_of_schedule', absences: '1 of 5')
    end

    before do
      child.business.update!(accredited: true, qris_rating: 'step_four')
      child_approval.update!(special_needs_rate: false)
      create(:nebraska_rate, :accredited, :hourly, :ldds, amount: 5.15, effective_on: Time.zone.parse('April 1st, 2021'), expires_on: nil)
      create(:nebraska_rate, :accredited, :daily, :ldds, amount: 25.15, effective_on: Time.zone.parse('April 1st, 2021'), expires_on: nil)
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
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['full_days']).to eq('3.0')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['hours_attended']).to eq('12.0')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['family_fee']).to eq('120.50')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['earned_revenue']).to eq('175.60')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['estimated_revenue']).to eq('265.40')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['attendance_risk']).to eq('ahead_of_schedule')
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: attendance_date))['absences']).to eq('1 of 5')
    end
    context 'when using live algorithms' do
      before do
        allow(Rails.application.config).to receive(:ff_ne_live_algorithms).and_return(true)
        travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours # first dashboard view date is Jul 8th, 2021 at 4pm
      end
      # rubocop:disable Rails/RedundantTravelBack
      after { travel_back }
      # rubocop:enable Rails/RedundantTravelBack
      let(:family_fee) { child.active_nebraska_approval_amount(attendance_date).family_fee }
      it 'includes the child name and all live attendance data' do
        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # 3 hours of attendance from the hourly attendance created above on the 4th
        expect(parsed_body['hours']).to eq('3.0')
        # 1 full day of attendance from the daily attendance created above on the 7th
        expect(parsed_body['full_days']).to eq('1.0')
        # hours this week only
        expect(parsed_body['hours_attended']).to eq("9.0 of #{child_approval.authorized_weekly_hours}")
        # no revenue because of family fee
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', 0.0))
        # this includes 3.0 of hourly attendance, 1 full day attendance + 17 remaining scheduled days of the month including today
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((3.0 * 5.15 * (1.05**1)) + (18 * 25.15 * (1.05**1))) - family_fee))
        # static over the course of the month
        expect(parsed_body['family_fee']).to eq(format('%.2f', family_fee))
        # too early in the month to show risk
        expect(parsed_body['attendance_risk']).to eq('not_enough_info')

        travel_to Time.current + 14.days # second dashboard view date is Jul 22nd, 2021 at 4pm

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # no new hourly attendance
        expect(parsed_body['hours']).to eq('3.0')
        # no new daily attendance
        expect(parsed_body['full_days']).to eq('1.0')
        # hours this week only - we've traveled ahead in time
        expect(parsed_body['hours_attended']).to eq("0.0 of #{child_approval.authorized_weekly_hours}")
        # still no revenue because of family fee
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', 0.0))
        # no new attendances, stays the same even though we've traveled
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((3.0 * 5.15 * (1.05**1)) + (8 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (3.0 * 5.15 * (1.05**1)) + (8 * 25.15 * (1.05**1)) = 227.4825
        # ratio: (227.48 - 580.97) / 580.97 = -0.61
        expect(parsed_body['attendance_risk']).to eq('at_risk')

        create(
          :attendance,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 16.days + 3.hours,
          check_out: attendance_date.to_datetime + 16.days + 6.hours + 15.minutes
        )

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # one new hourly attendance
        expect(parsed_body['hours']).to eq('6.25')
        # no new daily attendance
        expect(parsed_body['full_days']).to eq('1.0')
        # hours this week only, the attendance created above
        expect(parsed_body['hours_attended']).to eq("3.3 of #{child_approval.authorized_weekly_hours}") # hours this week only
        # still no revenue because of family fee
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', 0.0))
        # this includes prior 3.0 hourly, 1 full day, and new 3.25 hours of attendance + remaining 7 days
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (8 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (6.25 * 5.15 * (1.05**1)) + (8 * 25.15 * (1.05**1)) = 245.06
        # ratio: (245.06 - 580.97) / 580.97 = -0.58
        expect(parsed_body['attendance_risk']).to eq('at_risk')

        create(
          :attendance,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 15.days + 3.hours,
          check_out: attendance_date.to_datetime + 15.days + 9.hours + 18.minutes
        )

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # no new hourly attendance
        expect(parsed_body['hours']).to eq('6.25')
        # one new daily attendance
        expect(parsed_body['full_days']).to eq('2.0')
        # full days + hours duration counts as "hours attended this week"
        expect(parsed_body['hours_attended']).to eq("9.6 of #{child_approval.authorized_weekly_hours}")
        # broke past the family fee; this formula includes the 2 daily attendances and the 6.25 hourly attendances
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (2 * 25.15 * (1.05**1))) - family_fee))
        # this includes prior 6.25 hourly, 1 full day, and new 1 full day of attendance + remaining 7 days
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (9 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (6.25 * 5.15 * (1.05**1)) + (9 * 25.15 * (1.05**1)) = 271.46
        # ratio: (271.46 - 580.97) / 580.97 = -0.53
        expect(parsed_body['attendance_risk']).to eq('at_risk')

        create_list(
          :attendance,
          5,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 15.days + 3.hours,
          check_out: attendance_date.to_datetime + 15.days + 9.hours + 18.minutes
        )
        create_list(
          :nebraska_absence,
          3,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 15.days + 3.hours, absence: 'absence'
        )

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # 5 new daily attendance
        expect(parsed_body['full_days']).to eq('7.0')
        # 3 new absences
        expect(parsed_body['absences']).to eq('3 of 5')
        # This includes the 2 prior dailies, the 5 new full days, and the 3 new full-day absences
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (10 * 25.15 * (1.05**1))) - family_fee))
        # this includes prior 6.25 hourly, 2 full days, and 10 full days of attendance + remaining 7 days
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (17 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (6.25 * 5.15 * (1.05**1)) + (17 * 25.15 * (1.05**1)) = 482.72
        # ratio: (482.72 - 580.97) / 580.97 = -0.17
        expect(parsed_body['attendance_risk']).to eq('on_track')

        create_list(
          :nebraska_absence,
          3,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 15.days + 3.hours,
          absence: 'absence'
        )

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # no new daily attendance
        expect(parsed_body['full_days']).to eq('7.0')
        # 3 new absences
        expect(parsed_body['absences']).to eq('6 of 5')
        # This includes the 7 prior dailies, the 3 prior absences, and 2 of the new full-day absences because we've hit the monthly limit
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (12 * 25.15 * (1.05**1))) - family_fee))
        # earned revenue + remaining 7 days
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (19 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (6.25 * 5.15 * (1.05**1)) + (19 * 25.15 * (1.05**1)) = 535.54
        # ratio: (535.54 - 580.97) / 580.97 = -0.08
        expect(parsed_body['attendance_risk']).to eq('on_track')

        create(
          :nebraska_absence,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 15.days + 3.hours,
          absence: 'covid_absence'
        )

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # 1 new covid absence
        expect(parsed_body['absences']).to eq('7 of 5')
        # This includes the 7 prior dailies, the 5 prior absences, and this absence because COVID absences are unlimited at this time
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (13 * 25.15 * (1.05**1))) - family_fee))
        # earned revenue + remaining 7 days
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (20 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (6.25 * 5.15 * (1.05**1)) + (20 * 25.15 * (1.05**1)) = 561.95
        # ratio: (561.95 - 580.97) / 580.97 = -0.03
        expect(parsed_body['attendance_risk']).to eq('on_track')

        create(
          :attendance,
          child_approval: child_approval,
          check_in: Time.current - 7.hours,
          check_out: Time.current - 10.minutes
        )

        parsed_body = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        # 1 new daily attendance
        expect(parsed_body['full_days']).to eq('8.0')
        # This includes the 7 prior dailies, the 6 prior absences, and a new full-day attendance today
        expect(parsed_body['earned_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (14 * 25.15 * (1.05**1))) - family_fee))
        # earned revenue + remaining 6 days because there's an attendance today
        expect(parsed_body['estimated_revenue']).to eq(format('%.2f', ((6.25 * 5.15 * (1.05**1)) + (20 * 25.15 * (1.05**1))) - family_fee))
        # scheduled: 22 total scheduled days * 25.15 * (1.05**1) = 580.965
        # estimated: (6.25 * 5.15 * (1.05**1)) + (20 * 25.15 * (1.05**1)) = 561.95
        # ratio: (561.95 - 580.97) / 580.97 = -0.03
        expect(parsed_body['attendance_risk']).to eq('on_track')
      end
      it 'subtracts the family fee from the correct child' do
        child.attendances.destroy_all
        child_with_less_hours = create(
          :necc_child,
          business: child.business,
          date_of_birth: child.date_of_birth,
          effective_date: Time.zone.parse('July 1st, 2021'),
          schedules: [create(:schedule)],
          approvals: [approval]
        )

        create_list(
          :attendance,
          10,
          child_approval: child_approval,
          check_in: attendance_date.to_datetime + 3.hours,
          check_out: attendance_date.to_datetime + 6.hours
        )
        create_list(
          :attendance,
          10,
          child_approval: child_with_less_hours.active_child_approval(attendance_date),
          check_in: attendance_date.to_datetime + 3.hours,
          check_out: attendance_date.to_datetime + 6.hours
        )

        child.reload
        child_with_less_hours.reload

        child_json = JSON.parse(described_class.render(child, view: :nebraska_dashboard, filter_date: Time.current))
        child_with_less_hours_json = JSON.parse(described_class.render(child_with_less_hours, view: :nebraska_dashboard, filter_date: Time.current))

        expect(child_json['family_fee']).to eq(format('%.2f', family_fee))
        expect(child_with_less_hours_json['family_fee']).to eq(format('%.2f', 0))

        # even though they've both attended 10 times, the expectation is that the one with more hours will have less
        # revenue because we're subtracting the family fee from that child
        expect(child_json['earned_revenue']).to eq(format('%.2f', child_with_less_hours_json['earned_revenue'].to_f - 80.00))
      end
    end
  end
end
