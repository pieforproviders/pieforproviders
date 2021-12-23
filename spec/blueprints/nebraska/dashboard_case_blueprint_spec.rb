# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Nebraska::DashboardCaseBlueprint do
  let!(:child) { create(:necc_child, effective_date: Time.zone.parse('June 1st, 2021')) }
  let(:qris_bump) { 1.05**1 }
  let(:hourly_rate) { 5.15 }
  let(:daily_rate) { 25.15 }
  let(:family_fee) { child.active_nebraska_approval_amount(attendance_date).family_fee }
  let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:attendance_date) { Time.new(2021, 7, 4, 0, 0, 0, timezone).to_date }

  before do
    child.business.update!(accredited: true, qris_rating: 'step_four')
    child_approval.update!(attributes_for(:child_approval).merge({ full_days: 200,
                                                                   hours: 1800,
                                                                   special_needs_rate: false }))
    create(
      :accredited_hourly_ldds_rate,
      license_type: child.business.license_type,
      amount: 5.15,
      effective_on: Time.zone.parse('April 1st, 2021'),
      expires_on: nil
    )
    create(
      :accredited_daily_ldds_rate,
      license_type: child.business.license_type,
      amount: 25.15,
      effective_on: Time.zone.parse('April 1st, 2021'),
      expires_on: nil
    )
    create(
      :attendance,
      child_approval: child_approval,
      check_in: attendance_date.in_time_zone(child.timezone).to_datetime + 3.hours,
      check_out: attendance_date.in_time_zone(child.timezone).to_datetime + 6.hours
    )

    create(
      :attendance,
      child_approval: child_approval,
      check_in: Helpers.next_attendance_day(child_approval: child_approval) + 3.hours,
      check_out: Helpers.next_attendance_day(child_approval: child_approval) + 9.hours
    )

    # first dashboard view date is Jul 8th, 2021 at 4pm
    travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours
    child.reload
  end

  after { travel_back }

  it 'includes the child name and all cases' do
    expect(
      JSON.parse(described_class.render(Nebraska::DashboardCase.new(child: child, filter_date: Time.current))).keys
    ).to contain_exactly(
      'absences',
      'attendance_risk',
      'approval_effective_on',
      'approval_expires_on',
      'case_number',
      'earned_revenue',
      'estimated_revenue',
      'family_fee',
      'full_days',
      'full_days_authorized',
      'full_days_remaining',
      'hours',
      'hours_authorized',
      'hours_remaining',
      'hours_attended'
    )
  end

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations
  # Integration test that mimics the flow of a month of attendances and absences
  it 'includes the child name and all live attendance data' do
    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # 3 hours of attendance from the hourly attendance created above on the 4th
    expect(parsed_response['hours']).to eq('3.0')
    # 1 full day of attendance from the daily attendance created above on the 5th
    expect(parsed_response['full_days']).to eq('1.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 3).to_f)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 1)
    # hours this week only
    expect(parsed_response['hours_attended']).to eq("9.0 of #{child_approval.authorized_weekly_hours}")
    # no revenue because of family fee
    expect(parsed_response['earned_revenue']).to eq(0.0)
    # this includes 3.0 of hourly attendance, 1 full day attendance + 17
    # static over the course of the month
    expect(parsed_response['family_fee']).to eq(family_fee.to_f.to_s)
    # remaining scheduled days of the month including today
    expect(parsed_response['estimated_revenue'])
      .to eq(((3.0 * hourly_rate * qris_bump) + (18 * daily_rate * qris_bump) - family_fee).to_f.round(2))
    # too early in the month to show risk
    expect(parsed_response['attendance_risk']).to eq('not_enough_info')

    travel_to Time.current + 14.days # second dashboard view date is Jul 22nd, 2021 at 4pm

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # no new hourly attendance
    expect(parsed_response['hours']).to eq('3.0')
    # no new daily attendance
    expect(parsed_response['full_days']).to eq('1.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 3.0).to_f)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 1)
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # hours this week only - we've traveled ahead in time
    expect(parsed_response['hours_attended']).to eq("0.0 of #{child_approval.authorized_weekly_hours}")
    # still no revenue because of family fee
    expect(parsed_response['earned_revenue']).to eq(0.0)
    # no new attendances, stays the same even though we've traveled
    expect(parsed_response['estimated_revenue'])
      .to eq((((3.0 * hourly_rate * qris_bump) + (8 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (3.0 * hourly_rate * qris_bump) + (8 * daily_rate * qris_bump) = 227.4825
    # ratio: (227.48 - 580.97) / 580.97 = -0.61
    expect(parsed_response['attendance_risk']).to eq('at_risk')

    # July 6th, hourly
    create(
      :attendance,
      child_approval: child_approval,
      check_in: Helpers.next_attendance_day(child_approval: child_approval) + 3.hours,
      check_out: Helpers.next_attendance_day(child_approval: child_approval) + 6.hours + 15.minutes
    )

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # one new hourly attendance
    expect(parsed_response['hours']).to eq('6.25')
    # no new daily attendance
    expect(parsed_response['full_days']).to eq('1.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 1)
    # hours this week only - we've traveled ahead in time
    expect(parsed_response['hours_attended']).to eq("0.0 of #{child_approval.authorized_weekly_hours}")
    # still no revenue because of family fee
    expect(parsed_response['earned_revenue']).to eq(0.0)
    # this includes prior 3.0 hourly, 1 full day, and new 3.25 hours of attendance + remaining 7 days
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (8 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (6.25 * hourly_rate * qris_bump) + (8 * daily_rate * qris_bump) = 245.06
    # ratio: (245.06 - 580.97) / 580.97 = -0.58
    expect(parsed_response['attendance_risk']).to eq('at_risk')

    # July 7th, hourly
    create(
      :attendance,
      child_approval: child_approval,
      check_in: Helpers.next_attendance_day(child_approval: child_approval) + 3.hours,
      check_out: Helpers.next_attendance_day(child_approval: child_approval) + 9.hours + 18.minutes
    )

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # no new hourly attendance
    expect(parsed_response['hours']).to eq('6.25')
    # one new daily attendance
    expect(parsed_response['full_days']).to eq('2.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 2)
    # hours this week only - we've traveled ahead in time
    expect(parsed_response['hours_attended']).to eq("0.0 of #{child_approval.authorized_weekly_hours}")
    # broke past the family fee; this formula includes the 2 daily attendances and the 6.25 hourly attendances
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (2 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # this includes prior 6.25 hourly, 1 full day, and new 1 full day of attendance + remaining 7 days
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (9 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (6.25 * hourly_rate * qris_bump) + (9 * daily_rate * qris_bump) = 271.46
    # ratio: (271.46 - 580.97) / 580.97 = -0.53
    expect(parsed_response['attendance_risk']).to eq('at_risk')

    # July 8th - 12th
    # 5 full day attendances
    build_list(:attendance, 5) do |attendance|
      attendance.child_approval = child_approval
      attendance.check_in = Helpers.next_attendance_day(child_approval: child_approval) + 3.hours
      attendance.check_out = Helpers.next_attendance_day(child_approval: child_approval) + 9.hours + 18.minutes
      attendance.save!
    end

    # July 13th - 15th
    # 3 full day absences
    Helpers.build_nebraska_absence_list(num: 3, child_approval: child_approval)

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # 5 new daily attendances
    expect(parsed_response['full_days']).to eq('7.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
    # subtract full day attendances, subtract full day absences
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 7 - 3)
    # 3 new absences
    expect(parsed_response['absences']).to eq('3 of 5')
    # This includes the 2 prior dailies, the 5 new full days, and the 3 new full-day absences
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (10 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # this includes prior 6.25 hourly, 2 full days, and 10 full days of attendance + remaining 7 days
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (17 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (6.25 * hourly_rate * qris_bump) + (17 * daily_rate * qris_bump) = 482.72
    # ratio: (482.72 - 580.97) / 580.97 = -0.17
    expect(parsed_response['attendance_risk']).to eq('on_track')

    # July 16th, 19th, 20th
    Helpers.build_nebraska_absence_list(num: 3, child_approval: child_approval)

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # no new daily attendance
    expect(parsed_response['full_days']).to eq('7.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
    # subtract full day attendances, subtract full day absences up to limit
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 7 - 5)
    # 3 new absences
    expect(parsed_response['absences']).to eq('6 of 5')
    # This includes the 7 prior dailies, the 3 prior absences,
    # and 2 of the new full-day absences because we've hit the monthly limit
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (12 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # earned revenue + remaining 7 days
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (19 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (6.25 * hourly_rate * qris_bump) + (19 * daily_rate * qris_bump) = 535.54
    # ratio: (535.54 - 580.97) / 580.97 = -0.08
    expect(parsed_response['attendance_risk']).to eq('on_track')

    # July 21st
    Helpers.build_nebraska_absence_list(num: 1, type: 'covid_absence', child_approval: child_approval)

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # 1 new covid absence
    expect(parsed_response['absences']).to eq('7 of 5')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
    # subtract full day attendances, subtract full day absences up to the limit
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 7 - 5)
    # This includes the 7 prior dailies, the 5 prior absences,
    # and this absence because COVID absences are unlimited at this time
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (13 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # earned revenue + remaining 7 days
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump) = 561.95
    # ratio: (561.95 - 580.97) / 580.97 = -0.03
    expect(parsed_response['attendance_risk']).to eq('on_track')

    # July 22nd
    create(
      :attendance,
      child_approval: child_approval,
      check_in: Time.current - 7.hours,
      check_out: Time.current - 10.minutes
    )

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # 1 new daily attendance
    expect(parsed_response['full_days']).to eq('8.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
    # subtract full day attendances, subtract full day absences up to the limit
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 8 - 5)
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # This includes the 7 prior dailies, the 6 prior absences, and a new full-day attendance today
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # earned revenue + remaining 6 days because there's an attendance today
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
    # estimated: (6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump) = 561.95
    # ratio: (561.95 - 580.97) / 580.97 = -0.03
    expect(parsed_response['attendance_risk']).to eq('on_track')

    prior_month_check_in = child_approval.effective_on.in_time_zone(child.timezone).at_beginning_of_day

    create(
      :attendance,
      child_approval: child_approval,
      check_in: prior_month_check_in,
      check_out: prior_month_check_in + 3.hours
    )

    create(
      :attendance,
      child_approval: child_approval,
      check_in: prior_month_check_in + 1.day,
      check_out: prior_month_check_in + 1.day + 7.hours
    )

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # no change because this is an old attendance
    expect(parsed_response['full_days']).to eq('8.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25).to_f)
    # subtract full day attendances, subtract full day absences up to the limit
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 5)
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # no change because this is an old attendance
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['attendance_risk']).to eq('on_track')

    create(
      :attendance,
      child_approval: child_approval,
      check_in: prior_month_check_in + 2.days,
      check_out: nil,
      absence: 'covid_absence'
    )

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # no change because this is an old attendance
    expect(parsed_response['full_days']).to eq('8.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25).to_f)
    # subtract full day attendances, subtract full day absences up to the monthly limit (except covid absences)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 5)
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # no change because this is an old attendance
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['attendance_risk']).to eq('on_track')

    create(
      :attendance,
      child_approval: child_approval,
      check_in: prior_month_check_in + 3.days,
      check_out: nil,
      absence: 'absence'
    )

    parsed_response = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    # no change because this is an old attendance
    expect(parsed_response['full_days']).to eq('8.0')
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25).to_f)
    # subtract full day attendances, subtract full day absences up to the monthly limit (except covid absences)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 6)
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # no change because this is an old attendance
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['attendance_risk']).to eq('on_track')

    # this is to test an hourly absence in a prior-month, that is reliant on an hourly-duration schedule
    child.schedules.where(weekday: 2).first.update!(effective_on: Date.parse('July 1, 2021'), expires_on: nil)
    child.schedules << Schedule.create(
      weekday: 2,
      effective_on: child_approval.effective_on,
      expires_on: Date.parse('June 30, 2021'),
      duration: 3.hours
    )
    child.reload
    create(
      :attendance,
      child_approval: child_approval,
      check_in: Helpers.next_weekday(prior_month_check_in + 4.days, 2),
      check_out: nil,
      absence: 'absence'
    )

    parsed_response = JSON.parse(
      described_class
      .render(
        Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
      )
    )
    # Subtract an additional 3-hour absence from the prior hours_remaining
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25 - 3).to_f)

    # no change because this is an old attendance
    expect(parsed_response['full_days']).to eq('8.0')

    # subtract full day attendances, subtract full day absences up to the monthly limit
    # the original 5 limit applies to the attendance_date month; this absence occurs in the prior month
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 6)
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # no change because this is an old attendance
    expect(parsed_response['earned_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['estimated_revenue'])
      .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this is an old attendance
    expect(parsed_response['attendance_risk']).to eq('on_track')

    # change the current schedule to impact estimated revenue going forward for this month
    child.schedules.where(weekday: 2, effective_on: Date.parse('July 1, 2021')).first.update!(duration: 3.hours)
    child.reload

    parsed_response = JSON.parse(
      described_class
      .render(
        Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
      )
    )

    # changes two old Tuesday absences to 3-hour durations, 7/13, 7/20 and 6/8 are all 3 hour absences now,
    # but we're over our 5 attendance limit so only 7/20
    # has switched from counting towards hourly to counting towards daily
    expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25 - 6).to_f)
    expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 5)
    # this doesn't change because absences don't count towards calculated days/hours
    expect(parsed_response['full_days']).to eq('8.0')
    expect(parsed_response['hours']).to eq('6.25')
    expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
    expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
    # changes because of the new schedule - one more 3-hour attendance, one less daily attendance
    expect(parsed_response['earned_revenue'])
      .to eq((((9.25 * hourly_rate * qris_bump) + (13 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # changes because of the new schedule - we expect an additional
    # 3 hour scheduled day this month, and 1 less daily attendance
    # plus 7/20 moved from a daily to an hourly
    expect(parsed_response['estimated_revenue'])
      .to eq((((12.25 * hourly_rate * qris_bump) + (18 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
    # no change because this schedule change didn't impact risk
    expect(parsed_response['attendance_risk']).to eq('on_track')

    travel_back
  end

  it 'subtracts the family fee from the correct child' do
    child.service_days.destroy_all
    child_with_less_hours = create(
      :necc_child,
      business: child.business,
      date_of_birth: child.date_of_birth,
      schedules: [create(:schedule)],
      approvals: [child.approvals.first],
      effective_date: Time.zone.parse('June 1st, 2021')
    )

    child_with_less_hours.active_child_approval(attendance_date).update!(full_days: 300, hours: 1500)

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

    child_json = JSON.parse(
      described_class
        .render(
          Nebraska::DashboardCase.new(child: child, filter_date: Time.current)
        )
    )

    cwlh_dashboard_case = Nebraska::DashboardCase.new(child: child_with_less_hours, filter_date: Time.current)
    child_with_less_hours_json = JSON.parse(
      described_class.render(cwlh_dashboard_case)
    )

    expect(child_json['family_fee']).to eq(family_fee.to_f.to_s)
    expect(child_with_less_hours_json['family_fee']).to eq(0)

    # even though they've both attended 10 times, the expectation is that the one with more hours will have less
    # revenue because we're subtracting the family fee from that child
    expect(child_json['earned_revenue']).to eq([child_with_less_hours_json['earned_revenue'].to_f - 80.00, 0.0].max)
  end
  # rubocop:enable RSpec/MultipleExpectations
  # rubocop:enable RSpec/ExampleLength
end
# rubocop:enable Metrics/BlockLength
