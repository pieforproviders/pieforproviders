# frozen_string_literal: true

require 'rails_helper'

# This is our orchestrator class so we're doing integration tests here
# rubocop:disable Metrics/BlockLength
RSpec.describe Nebraska::EarnedRevenueCalculator, type: :service do
  subject { described_class.new(child, date) }

  # This 
  let(:child) do
    create(
      :necc_child,
      date_of_birth: 'April 25th, 2020', # the child will age from infant to toddler mid-month
      effective_date: DateTime.parse('Aug 1st, 2021, 8am Central'),
      business: create(:business, :nebraska, :accredited, :not_rated)
    )
  end
  let(:date) { DateTime.parse('October 31st, 2021 8am Central') }
  let(:child_approval) { child.child_approvals.first }

  describe '#call' do
    context 'with an accredited fcchi business, Douglas county, no qris, non-special-needs' do
      let!(:infant_hourly_rate) do
        create(
          :accredited_hourly_ldds_rate,
          effective_on: check_in - 6.months,
          expires_on: nil,
          max_age: 18
        )
      end
      let!(:infant_daily_rate) do
        create(
          :accredited_daily_ldds_rate,
          effective_on: check_in - 6.months,
          expires_on: nil,
          max_age: 18
        )
      end
      let(:check_in) { DateTime.parse('October 4th, 2021 8am Central') }
      let(:date) { check_in.at_end_of_month }
      let(:child) do
        create(
          :necc_child,
          date_of_birth: 'April 25th, 2020', # the child will age from infant to toddler mid-month
          effective_date: DateTime.parse('Aug 1st, 2021, 8am Central'),
          business: create(:business, :nebraska, :accredited, :not_rated)
        )
      end

      context 'with hourly attendances' do
        let!(:attendance) do
          create(
            :nebraska_hourly_attendance,
            check_in: check_in,
            child_approval: child_approval
          )
        end

        it 'returns earned revenue for a single attendance' do
          expect(subject.call).to eq(infant_hourly_rate.amount.to_f * service_day.duration)
        end

        context 'with multiple attendances' do
          let(:second_attendance) do
            create(
              :nebraska_hourly_attendance,
              check_in: check_in + 3.days,
              check_out: check_in + 3.days + 2.hours,
              child_approval: child_approval
            )
          end

          it 'returns earned revenue for multiple attendances on different days' do
            expect(subject.call)
              .to eq(
                infant_hourly_rate.amount.to_f *
                (
                  attendance.service_day.duration +
                  second_attendance.service_day.duration
                )
              )
            third_attendance = create(
              :nebraska_hourly_attendance,
              check_in: check_in + 4.days,
              child_approval: child_approval
            )
            expect(subject.call).to eq(
              infant_hourly_rate.amount.to_f *
              (
                attendance.service_day.duration +
                second_attendance.service_day.duration +
                third_attendance.service_day.duration
              )
            )
          end

          it 'returns earned revenue for multiple same-day attendances' do
            # should be the same service day as second_attendance
            create(
              :nebraska_hourly_attendance,
              check_in: check_in + 3.days + 6.hours,
              check_out: check_in + 3.days + 7.hours
            )
            expect(subject.call)
              .to eq(
                infant_hourly_rate.amount.to_f *
                (
                  attendance.service_day.duration +
                  second_attendance.service_day.duration
                )
              )
          end

          it 'returns earned revenue for multiple attendances with attendances in prior months' do
            create(:nebraska_hourly_attendance, check_in: check_in - 1.month, child_approval: child_approval)
            expect(subject.call)
              .to eq(
                infant_hourly_rate.amount.to_f *
                (
                  attendance.service_day.duration +
                  second_attendance.service_day.duration
                )
              )
          end
        end
      end

      context 'with daily attendances' do
        let!(:attendance) do
          create(
            :nebraska_daily_attendance,
            check_in: check_in,
            child_approval: child_approval
          )
        end

        it 'returns earned revenue for a single attendance' do
          expect(subject.call).to eq(infant_daily_rate.amount.to_f * service_day.duration)
        end

        context 'with multiple attendances' do
          let(:second_attendance) do
            create(
              :nebraska_daily_attendance,
              check_in: check_in + 3.days,
              check_out: check_in + 3.days + 6.hours,
              child_approval: child_approval
            )
          end

          it 'returns earned revenue for multiple attendances on different days' do
            expect(subject.call)
              .to eq(
                infant_daily_rate.amount.to_f *
                (
                  attendance.service_day.duration +
                  second_attendance.service_day.duration
                )
              )
            third_attendance = create(
              :nebraska_daily_attendance,
              check_in: check_in + 4.days,
              child_approval: child_approval
            )
            expect(subject.call).to eq(
              infant_daily_rate.amount.to_f *
              (
                attendance.service_day.duration +
                second_attendance.service_day.duration +
                third_attendance.service_day.duration
              )
            )
          end

          it 'returns earned revenue for multiple same-day attendances' do
            expect(subject.call)
              .to eq(
                infant_daily_rate.amount.to_f *
                (
                    attendance.service_day.duration +
                    second_attendance.service_day.duration
                  )
              )
            # should be the same service day as second_attendance, adds one more hour to the original duration
            create(
              :nebraska_hourly_attendance,
              check_in: check_in + 3.days + 6.hours,
              check_out: check_in + 3.days + 7.hours
            )
            expect(subject.call)
              .to eq(
                infant_daily_rate.amount.to_f *
                (
                  attendance.service_day.duration +
                  second_attendance.service_day.duration
                )
              )
          end

          it 'returns earned revenue for multiple attendances with attendances in prior months' do
            create(:nebraska_daily_attendance, check_in: check_in - 1.month, child_approval: child_approval)
            expect(subject.call)
              .to eq(
                infant_daily_rate.amount.to_f *
                (
                  attendance.service_day.duration +
                    second_attendance.service_day.duration
                )
              )
          end
        end
      end

      context 'with hourly and daily attendances' do
        let!(:attendance) do
          create(
            :nebraska_daily_attendance,
            check_in: check_in,
            child_approval: child_approval
          )
        end

        let(:second_attendance) do
          create(
            :nebraska_hourly_attendance,
            check_in: check_in + 3.days,
            check_out: check_in + 3.days + 1.hour,
            child_approval: child_approval
          )
        end

        it 'returns earned revenue for multiple attendances on different days' do
          expect(subject.call)
            .to eq(
              (
                infant_daily_rate.amount.to_f *
                  attendance.service_day.duration
              ) +
              (
                infant_hourly_rate.amount.to_f *
                second_attendance.service_day.duration
              )
            )
          third_attendance = create(
            :nebraska_daily_attendance,
            check_in: check_in + 4.days,
            child_approval: child_approval
          )
          expect(subject.call)
            .to eq(
              (
                infant_daily_rate.amount.to_f * (
                  attendance.service_day.duration +
                  third_attendance.service_day.duration
                )
              ) +
              (
                infant_hourly_rate.amount.to_f *
                second_attendance.service_day.duration
              )
            )
        end

        it 'returns earned revenue for multiple same-day attendances when the attendance type stays the same' do
          expect(subject.call)
            .to eq(
              (
                infant_daily_rate.amount.to_f *
                attendance.service_day.duration
              ) +
              (
                infant_hourly_rate.amount.to_f *
                second_attendance.service_day.duration
              )
            )
          # adds another hour to the hourly attendance, which should keep it in the hourly type
          third_attendance = create(
            :nebraska_daily_attendance,
            check_in: check_in + 3.days + 5.hours,
            check_out: check_in + 3.days + 6.hours,
            child_approval: child_approval
          )
          expect(subject.call)
            .to eq(
              (
                infant_daily_rate.amount.to_f * (
                  attendance.service_day.duration +
                  third_attendance.service_day.duration
                )
              ) +
              (
                infant_hourly_rate.amount.to_f *
                second_attendance.service_day.duration
              )
            )
        end

        it 'returns earned revenue for multiple same-day attendances when the attendance type changes' do
          expect(subject.call)
            .to eq(
              (
                infant_daily_rate.amount.to_f *
                attendance.service_day.duration
              ) +
              (
                infant_hourly_rate.amount.to_f *
                second_attendance.service_day.duration
              )
            )
          # adds 6 hours to the hourly attendance, which should push it into a daily duration
          create(
            :nebraska_daily_attendance,
            check_in: check_in + 3.days + 5.hours,
            check_out: check_in + 3.days + 11.hours,
            child_approval: child_approval
          )
          expect(subject.call)
            .to eq(
              (
                infant_daily_rate.amount.to_f * (
                  attendance.service_day.duration +
                  second_attendance.service_day.duration
                )
              )
            )
        end

        it 'returns earned revenue for multiple attendances with attendances in prior months' do
          expect(subject.call)
            .to eq(
              infant_daily_rate.amount.to_f *
              (
                attendance.service_day.duration +
                second_attendance.service_day.duration
              )
            )
          create(:nebraska_hourly_attendance, check_in: check_in - 1.month, child_approval: child_approval)
          expect(subject.call)
            .to eq(
              infant_daily_rate.amount.to_f *
              (
                attendance.service_day.duration +
                second_attendance.service_day.duration
              )
            )
        end
      end

      # TODO: write specs for child hitting absence limit
      # TODO: write specs for child schedules and absences
      # TODO: BIG todo - MOVE these tests where they belong, into an integration test or something similar

      # Currently skipping as out of scope for PIE-1717
      # context 'when a child ages up in the middle of a month' do
      #   let(:toddler_hourly_rate) do
      #     create(
      #       :accredited_hourly_ldds_rate,
      #       effective_on: check_in - 6.months,
      #       expires_on: nil,
      #       max_age: 36
      #     )
      #   end
      #   let(:preschool_hourly_rate) do
      #     create(
      #       :accredited_hourly_ldds_rate,
      #       effective_on: check_in - 6.months,
      #       expires_on: nil,
      #       max_age: nil
      #     )
      #   end

      #   it 'uses infant rates for the beginning of the month, then toddler rates for the days after the birthday' do
      #     # From model doc:
      #     # Note: It is assumed that as of 18 months and 0 days a child transitions from Infant to Toddler
      #     # (i.e. as of that day, the child is considered a Toddler).
      #     # However, as of 2/15/21, this change in age bracket / rate will not occur until the following month
      #     # (to be clarified with state)
      #     second_attendance = create(:nebraska_hourly_attendance, check_in: check_in + 18.days, child_approval: child_approval)
      #     expect(subject.call)
      #     .to eq(
      #       (infant_daily_rate.amount.to_f * attendance.service_day.duration) +
      #       (toddler_hourly_rate.amount.to_f * second_attendance.service_day.duration)
      #     )
      #   end

      #   it 'uses toddler rates for the beginning of the month, then preschool rates for the days after the birthday' do
      #     child.update!(date_of_birth: 'October 25th, 2018')
      #     second_attendance = create(:nebraska_hourly_attendance, check_in: check_in + 18.days, child_approval: child_approval)
      #     expect(subject.call)
      #     .to eq(
      #       (toddler_hourly_rate.amount.to_f * attendance.service_day.duration) +
      #       (preschool_hourly_rate.amount.to_f * second_attendance.service_day.duration)
      #     )
      #   end
      # end
    end
  end
end
# rubocop:enable Metrics/BlockLength
