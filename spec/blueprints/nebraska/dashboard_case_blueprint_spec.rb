# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Nebraska::DashboardCaseBlueprint do
  include_context 'with nebraska child created for dashboard'
  include_context 'with nebraska rates created for dashboard'

  before do
    # first dashboard view date is Jul 8th, 2021 at 4pm
    travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours
  end

  after { travel_back }

  it 'includes the child name and all cases' do
    expect(
      JSON.parse(described_class.render(
                   Nebraska::DashboardCase.new(
                     child: child,
                     filter_date: Time.current,
                     service_days: child.child_approvals.first.service_days
                   )
                 )).keys
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

  # Integration tests that mimic the flow of a month of attendances and absences
  describe 'with base attendances' do
    include_context 'with attendances on July 4th and 5th' # Sunday, July 4th and Monday, July 5th base attendances
    context 'when rendered on July 8th, 2021' do
      before do
        travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours
      end

      after { travel_back }

      it 'renders correct data' do
        child.service_days.each(&:reload)
        parsed_response = JSON.parse(
          described_class
            .render(
              Nebraska::DashboardCase.new(child: child,
                                          filter_date: Time.current,
                                          service_days: child.child_approvals.first.service_days)
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
      end
    end

    context 'when rendered on July 22nd, 2021' do
      before do
        travel_to 14.days.from_now # second dashboard view date is Jul 22nd, 2021 at 4pm
      end

      after { travel_back }

      it 'renders correct data' do
        child.service_days.each(&:reload)
        parsed_response = JSON.parse(
          described_class
            .render(
              Nebraska::DashboardCase.new(child: child,
                                          filter_date: Time.current,
                                          service_days: child.child_approvals.first.service_days)
            )
        )

        # hours this week only - we've traveled ahead in time
        expect(parsed_response['hours_attended']).to eq("0.0 of #{child_approval.authorized_weekly_hours}")
        expect(parsed_response['hours']).to eq('3.0')
        expect(parsed_response['full_days']).to eq('1.0')
        expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 3.0).to_f)
        expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 1)
        expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
        expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
        # still no revenue because of family fee
        expect(parsed_response['earned_revenue']).to eq(0.0)
        # no new attendances, stays the same even though we've traveled
        expect(parsed_response['estimated_revenue'])
          .to eq((((3.0 * hourly_rate * qris_bump) + (8 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
        # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
        # estimated: (3.0 * hourly_rate * qris_bump) + (8 * daily_rate * qris_bump) = 227.4825
        # ratio: (227.48 - 580.97) / 580.97 = -0.61
        expect(parsed_response['attendance_risk']).to eq('at_risk')
      end

      # rubocop:disable RSpec/NestedGroups
      describe 'with prior attendances and an additional hourly attendance' do
        include_context 'with an hourly attendance' # Tuesday, July 6th

        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
              )
          )

          # one new hourly attendance
          expect(parsed_response['hours']).to eq('6.25')
          expect(parsed_response['full_days']).to eq('1.0')
          expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
          expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 1)
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
        end
      end

      describe 'with prior attendances and an additional daily attendance' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th

        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
              )
          )

          # one new daily attendance
          expect(parsed_response['full_days']).to eq('2.0')
          expect(parsed_response['hours']).to eq('6.25')
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
        end
      end

      describe 'with prior attendances and five daily attendances and three full day absences' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th

        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
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
        end
      end

      describe 'with prior attendances and six full day absences' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th
        include_context 'with an absence' # Friday, July 16th
        include_context 'with an absence' # Monday, July 19th
        include_context 'with an absence' # Tuesday, July 20th
        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
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
        end
      end

      describe 'with prior attendances and a COVID absence' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th
        include_context 'with an absence' # Friday, July 16th
        include_context 'with an absence' # Monday, July 19th
        include_context 'with an absence' # Tuesday, July 20th
        include_context 'with a covid absence' # Wednesday, July 21st
        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
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
        end
      end

      describe 'with prior attendances and six full day attendances' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th
        include_context 'with an absence' # Friday, July 16th
        include_context 'with an absence' # Monday, July 19th
        include_context 'with an absence' # Tuesday, July 20th
        include_context 'with a covid absence' # Wednesday, July 21st
        include_context 'with a daily attendance' # Thursday, July 22nd
        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
              )
          )

          # 1 new daily attendance
          expect(parsed_response['full_days']).to eq('8.0')
          # 8 full day attendances, 5 full day absences (up to the limit)
          expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 8 - 5)

          # no change
          expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 6.25).to_f)
          expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
          expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)

          # This includes the 7 prior dailies, the 6 prior absences (5 plus COVID), and a new full-day attendance today
          expect(parsed_response['earned_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          # earned revenue + remaining 6 days because there's an attendance today
          expect(parsed_response['estimated_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          # scheduled: 22 total scheduled days * daily_rate * qris_bump = 580.965
          # estimated: (6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump) = 561.95
          # ratio: (561.95 - 580.97) / 580.97 = -0.03
          expect(parsed_response['attendance_risk']).to eq('on_track')
        end
      end

      describe 'with prior attendances and two attendances in the prior month' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th
        include_context 'with an absence' # Friday, July 16th
        include_context 'with an absence' # Monday, July 19th
        include_context 'with an absence' # Tuesday, July 20th
        include_context 'with a covid absence' # Wednesday, July 21st
        include_context 'with a daily attendance' # Thursday, July 22nd
        include_context 'with a prior month daily attendance' # Tuesday, June 1st
        include_context 'with a prior month hourly attendance', 1 # Wednesday, June 2nd

        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
              )
          )

          # 9 full days + 5 full day absences
          expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 5)
          # no change because this is a prior attendance
          expect(parsed_response['full_days']).to eq('8.0')
          expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25).to_f)
          expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
          expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
          expect(parsed_response['earned_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          expect(parsed_response['estimated_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          expect(parsed_response['attendance_risk']).to eq('on_track')
        end
      end

      describe 'with prior attendances and a COVID absence in the prior month' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th
        include_context 'with an absence' # Friday, July 16th
        include_context 'with an absence' # Monday, July 19th
        include_context 'with an absence' # Tuesday, July 20th
        include_context 'with a covid absence' # Wednesday, July 21st
        include_context 'with a daily attendance' # Thursday, July 22nd
        include_context 'with a prior month daily attendance' # Tuesday, June 1st
        include_context 'with a prior month hourly attendance', 1 # Wednesday, June 2nd
        include_context 'with a prior month covid absence', 2 # Thursday, June 3rd

        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
              )
          )

          # no change because this is a prior COVID absence
          # doesn't count towards authorization, doesn't count towards current revenue
          expect(parsed_response['full_days']).to eq('8.0')
          expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 5)
          expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25).to_f)
          expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
          expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
          expect(parsed_response['earned_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          expect(parsed_response['estimated_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          expect(parsed_response['attendance_risk']).to eq('on_track')
        end
      end

      describe 'with prior attendances and a regular absence in the prior month' do
        include_context 'with an hourly attendance' # Tuesday, July 6th
        include_context 'with a daily attendance' # Wednesday, July 7th
        include_context 'with a daily attendance' # Thursday, July 8th
        include_context 'with a daily attendance' # Friday, July 9th
        include_context 'with a daily attendance' # Saturday, July 10th
        include_context 'with a daily attendance' # Sunday, July 11th
        include_context 'with a daily attendance' # Monday, July 12th
        include_context 'with an absence' # Tuesday, July 13th
        include_context 'with an absence' # Wednesday, July 14th
        include_context 'with an absence' # Thursday, July 15th
        include_context 'with an absence' # Friday, July 16th
        include_context 'with an absence' # Monday, July 19th
        include_context 'with an absence' # Tuesday, July 20th
        include_context 'with a covid absence' # Wednesday, July 21st
        include_context 'with a daily attendance' # Thursday, July 22nd
        include_context 'with a prior month daily attendance' # Tuesday, June 1st
        include_context 'with a prior month hourly attendance', 1 # Wednesday, June 2nd
        include_context 'with a prior month covid absence', 2 # Thursday, June 3rd
        include_context 'with a prior month absence', 3 # Friday, June 4th

        it 'renders correct data' do
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
              .render(
                Nebraska::DashboardCase.new(child: child,
                                            filter_date: Time.current,
                                            service_days: child.child_approvals.first.service_days)
              )
          )

          # 9 full day attendances, 5 full day absences in July, 1 full day absence in June
          expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 6)
          # no change because this is a prior attendance
          expect(parsed_response['full_days']).to eq('8.0')
          expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25).to_f)
          expect(parsed_response['hours_authorized']).to eq(child_approval.hours.to_f)
          expect(parsed_response['full_days_authorized']).to eq(child_approval.full_days)
          expect(parsed_response['earned_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (14 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          expect(parsed_response['estimated_revenue'])
            .to eq((((6.25 * hourly_rate * qris_bump) + (20 * daily_rate * qris_bump)) - family_fee).to_f.round(2))
          expect(parsed_response['attendance_risk']).to eq('on_track')
        end

        it 'renders correct data with schedule changes' do
          child.schedules.where(weekday: 2).first.update!(expires_on: Date.parse('June 30, 2021'))
          child.schedules << Schedule.create(
            weekday: 2,
            effective_on: Date.parse('July 1, 2021'),
            expires_on: nil,
            duration: 3.hours
          )
          child.service_days.each(&:reload)
          parsed_response = JSON.parse(
            described_class
            .render(
              Nebraska::DashboardCase.new(
                child: child,
                filter_date: Time.current,
                service_days: child.child_approvals.first.service_days
              )
            )
          )
          expect(parsed_response['hours_remaining']).to eq((child_approval.hours - 9.25 - 3).to_f)
          expect(parsed_response['full_days_remaining']).to eq(child_approval.full_days - 9 - 5)
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
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
          Nebraska::DashboardCase.new(
            child: child,
            filter_date: Time.current,
            service_days: child.child_approvals.first.service_days
          )
        )
    )

    cwlh_dashboard_case = Nebraska::DashboardCase.new(
      child: child_with_less_hours,
      filter_date: Time.current,
      service_days: child_with_less_hours.child_approvals.first.service_days
    )
    child_with_less_hours_json = JSON.parse(
      described_class.render(cwlh_dashboard_case)
    )

    expect(child_json['family_fee']).to eq(family_fee.to_f.to_s)
    expect(child_with_less_hours_json['family_fee']).to eq(0)

    # even though they've both attended 10 times, the expectation is that the one with more hours will have less
    # revenue because we're subtracting the family fee from that child
    expect(child_json['earned_revenue']).to eq([child_with_less_hours_json['earned_revenue'].to_f - 80.00, 0.0].max)
  end
end
# rubocop:enable Metrics/BlockLength
