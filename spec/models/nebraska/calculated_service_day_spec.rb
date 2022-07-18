# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/NestedGroups
RSpec.describe Nebraska::CalculatedServiceDay, type: :model do
  describe '#earned_revenue' do
    let!(:date) { '2022-06-30'.to_date.at_beginning_of_day }
    let!(:child) do
      create(
        :necc_child,
        business: create(
          :business,
          :nebraska_ldds,
          accredited: true,
          qris_rating: 'not_rated'
        )
      )
    end
    let!(:business) { child.business }
    let!(:nebraska_accredited_hourly_rate) do
      create(
        :accredited_hourly_ldds_rate,
        license_type: business.license_type,
        max_age: child.age + 4.years,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_accredited_daily_rate) do
      create(
        :accredited_daily_ldds_rate,
        license_type: business.license_type,
        max_age: child.age + 4.years,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_unaccredited_hourly_rate) do
      create(
        :unaccredited_hourly_ldds_rate,
        license_type: business.license_type,
        max_age: child.age + 4.years,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_unaccredited_daily_rate) do
      create(
        :unaccredited_daily_ldds_rate,
        license_type: business.license_type,
        max_age: child.age + 4.years,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_school_age_unaccredited_hourly_rate) do
      create(
        :unaccredited_hourly_ldds_school_age_rate,
        license_type: business.license_type,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_school_age_unaccredited_daily_rate) do
      create(
        :unaccredited_daily_ldds_school_age_rate,
        license_type: business.license_type,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_school_age_unaccredited_non_urban_hourly_rate) do
      create(
        :unaccredited_hourly_other_region_school_age_rate,
        license_type: business.license_type,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end
    let!(:nebraska_school_age_unaccredited_non_urban_daily_rate) do
      create(
        :unaccredited_daily_other_region_school_age_rate,
        license_type: business.license_type,
        effective_on: 1.year.ago,
        expires_on: 1.year.from_now,
        county: business.county
      )
    end

    let(:rates) do
      NebraskaRate.for_case(
        date,
        child.child_approvals&.first&.enrolled_in_school || false,
        child.age_in_months(date),
        child.business
      )
    end

    let!(:service_day) { build(:service_day, child: child, date: date) }
    let!(:child_approvals) { child.child_approvals }

    context 'with an accredited business' do
      it 'gets rates for an hourly-only service_day' do
        service_day.total_time_in_care = 3.25.hours
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(3.25 * nebraska_accredited_hourly_rate.amount)
      end

      it 'gets rates for a daily-only service_day' do
        service_day.total_time_in_care = 6.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(1 * nebraska_accredited_daily_rate.amount)
      end

      it 'gets rates for a daily-plus-hourly service_day' do
        service_day.total_time_in_care = 12.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (2.25 * nebraska_accredited_hourly_rate.amount) + (1 * nebraska_accredited_daily_rate.amount)
        )
      end

      it 'gets rates for a service_day at the max of 18 hours' do
        service_day.total_time_in_care = 21.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (8 * nebraska_accredited_hourly_rate.amount) + (1 * nebraska_accredited_daily_rate.amount)
        )
      end

      context 'with a special needs approved child' do
        before do
          child.child_approvals.first.update!(
            special_needs_rate: true,
            special_needs_daily_rate: 20.0,
            special_needs_hourly_rate: 5.60
          )
        end

        it 'gets rates for an hourly-only service_day' do
          service_day.total_time_in_care = 3.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(3.25 * child.child_approvals.first.special_needs_hourly_rate)
        end

        it 'gets rates for a daily-only service_day' do
          service_day.total_time_in_care = 6.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(1 * child.child_approvals.first.special_needs_daily_rate)
        end

        it 'gets rates for a daily-plus-hourly service_day' do
          service_day.total_time_in_care = 12.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (2.25 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end

        it 'gets rates for a service_day at the max of 18 hours' do
          service_day.total_time_in_care = 21.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (8 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end
      end
    end

    context 'with an unaccredited business' do
      before do
        business.update!(accredited: false)
      end

      it 'gets rates for an hourly-only service_day' do
        service_day.total_time_in_care = 3.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(3.25 * nebraska_unaccredited_hourly_rate.amount)
      end

      it 'gets rates for a daily-only service_day' do
        service_day.total_time_in_care = 6.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(1 * nebraska_unaccredited_daily_rate.amount)
      end

      it 'gets rates for a daily-plus-hourly service_day' do
        service_day.total_time_in_care = 12.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (2.25 * nebraska_unaccredited_hourly_rate.amount) +
          (1 * nebraska_unaccredited_daily_rate.amount)
        )
      end

      it 'gets rates for a service_day at the max of 18 hours' do
        service_day.total_time_in_care = 21.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (8 * nebraska_unaccredited_hourly_rate.amount) +
          (1 * nebraska_unaccredited_daily_rate.amount)
        )
      end

      context 'with a special needs approved child' do
        before do
          child.child_approvals.first.update!(
            special_needs_rate: true,
            special_needs_daily_rate: 20.0,
            special_needs_hourly_rate: 5.60
          )
        end

        it 'gets rates for an hourly-only service_day' do
          service_day.total_time_in_care = 3.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(3.25 * child.child_approvals.first.special_needs_hourly_rate)
        end

        it 'gets rates for a daily-only service_day' do
          service_day.total_time_in_care = 6.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(1 * child.child_approvals.first.special_needs_daily_rate)
        end

        it 'gets rates for a daily-plus-hourly service_day' do
          service_day.total_time_in_care = 12.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (2.25 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end

        it 'gets rates for a service_day at the max of 18 hours' do
          service_day.total_time_in_care = 21.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (8 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end
      end
    end

    context 'with an accredited business with a qris_bump' do
      before do
        business.update!(accredited: true, qris_rating: 'step_five')
      end

      it 'gets rates for an hourly-only service_day' do
        service_day.total_time_in_care = 3.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(3.25 * nebraska_accredited_hourly_rate.amount * (1.05**2))
      end

      it 'gets rates for a daily-only service_day' do
        service_day.total_time_in_care = 6.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(1 * nebraska_accredited_daily_rate.amount * (1.05**2))
      end

      it 'gets rates for a daily-plus-hourly service_day' do
        service_day.total_time_in_care = 12.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (2.25 * nebraska_accredited_hourly_rate.amount * (1.05**2)) +
          (1 * nebraska_accredited_daily_rate.amount * (1.05**2))
        )
      end

      it 'gets rates for a service_day at the max of 18 hours' do
        service_day.total_time_in_care = 21.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (8 * nebraska_accredited_hourly_rate.amount * (1.05**2)) +
          (1 * nebraska_accredited_daily_rate.amount * (1.05**2))
        )
      end

      context 'with a special needs approved child' do
        before do
          child.child_approvals.first.update!(
            special_needs_rate: true,
            special_needs_daily_rate: 20.0,
            special_needs_hourly_rate: 5.60
          )
        end

        it 'gets rates for an hourly-only service_day' do
          service_day.total_time_in_care = 3.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(3.25 * child.child_approvals.first.special_needs_hourly_rate)
        end

        it 'gets rates for a daily-only service_day' do
          service_day.total_time_in_care = 6.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(1 * child.child_approvals.first.special_needs_daily_rate)
        end

        it 'gets rates for a daily-plus-hourly service_day' do
          service_day.total_time_in_care = 12.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (2.25 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end

        it 'gets rates for a service_day at the max of 18 hours' do
          service_day.total_time_in_care = 21.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (8 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end
      end
    end

    context 'with an unaccredited business with a qris_bump' do
      before do
        business.update!(accredited: false, qris_rating: 'step_five')
        child.child_approvals.first.update!(special_needs_rate: false)
      end

      it 'gets rates for an hourly-only service_day' do
        service_day.total_time_in_care = 3.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(3.25 * nebraska_unaccredited_hourly_rate.amount * (1.05**3))
      end

      it 'gets rates for a daily-only service_day' do
        service_day.total_time_in_care = 6.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(1 * nebraska_unaccredited_daily_rate.amount * (1.05**3))
      end

      it 'gets rates for a daily-plus-hourly service_day' do
        service_day.total_time_in_care = 12.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (2.25 * nebraska_unaccredited_hourly_rate.amount * (1.05**3)) +
          (1 * nebraska_unaccredited_daily_rate.amount * (1.05**3))
        )
      end

      it 'gets rates for a service_day at the max of 18 hours' do
        service_day.total_time_in_care = 21.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (8 * nebraska_unaccredited_hourly_rate.amount * (1.05**3)) +
          (1 * nebraska_unaccredited_daily_rate.amount * (1.05**3))
        )
      end

      context 'with a special needs approved child' do
        before do
          child.child_approvals.first.update!(
            special_needs_rate: true,
            special_needs_daily_rate: 20.0,
            special_needs_hourly_rate: 5.60
          )
        end

        it 'gets rates for an hourly-only service_day' do
          service_day.total_time_in_care = 3.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(3.25 * child.child_approvals.first.special_needs_hourly_rate)
        end

        it 'gets rates for a daily-only service_day' do
          service_day.total_time_in_care = 6.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(1 * child.child_approvals.first.special_needs_daily_rate)
        end

        it 'gets rates for a daily-plus-hourly service_day' do
          service_day.total_time_in_care = 12.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (2.25 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end

        it 'gets rates for a service_day at the max of 18 hours' do
          service_day.total_time_in_care = 21.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (8 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end
      end
    end

    context 'with a school age child with an unaccredited qris bump' do
      before do
        business.update!(accredited: false, qris_rating: 'step_five')
        child.child_approvals.first.update!(special_needs_rate: false, enrolled_in_school: true)
      end

      it 'gets rates for an hourly-only service_day' do
        service_day.total_time_in_care = 3.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(3.25 * nebraska_school_age_unaccredited_hourly_rate.amount * (1.05**3))
      end

      it 'gets rates for a daily-only service_day' do
        service_day.total_time_in_care = 6.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(1 * nebraska_school_age_unaccredited_daily_rate.amount * (1.05**3))
      end

      it 'gets rates for a daily-plus-hourly service_day' do
        service_day.total_time_in_care = 12.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (2.25 * nebraska_school_age_unaccredited_hourly_rate.amount * (1.05**3)) +
          (1 * nebraska_school_age_unaccredited_daily_rate.amount * (1.05**3))
        )
      end

      it 'gets rates for a service_day at the max of 18 hours' do
        service_day.total_time_in_care = 21.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (8 * nebraska_school_age_unaccredited_hourly_rate.amount * (1.05**3)) +
          (1 * nebraska_school_age_unaccredited_daily_rate.amount * (1.05**3))
        )
      end

      context 'with a special needs approved child' do
        before do
          child.child_approvals.first.update!(
            special_needs_rate: true,
            special_needs_daily_rate: 20.0,
            special_needs_hourly_rate: 5.60
          )
        end

        it 'gets rates for an hourly-only service_day' do
          service_day.total_time_in_care = 3.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(3.25 * child.child_approvals.first.special_needs_hourly_rate)
        end

        it 'gets rates for a daily-only service_day' do
          service_day.total_time_in_care = 6.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(1 * child.child_approvals.first.special_needs_daily_rate)
        end

        it 'gets rates for a daily-plus-hourly service_day' do
          service_day.total_time_in_care = 12.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (2.25 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end

        it 'gets rates for a service_day at the max of 18 hours' do
          service_day.total_time_in_care = 21.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (8 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end
      end
    end

    context 'with a school age child with an unaccredited qris bump in a non-LDDS county' do
      before do
        business.update!(accredited: false, qris_rating: 'step_five', county: 'Parker')
        child.child_approvals.first.update!(special_needs_rate: false, enrolled_in_school: true)
      end

      it 'gets rates for an hourly-only service_day' do
        service_day.total_time_in_care = 3.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(3.25 * nebraska_school_age_unaccredited_non_urban_hourly_rate.amount * (1.05**3))
      end

      it 'gets rates for a daily-only service_day' do
        service_day.total_time_in_care = 6.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(1 * nebraska_school_age_unaccredited_non_urban_daily_rate.amount * (1.05**3))
      end

      it 'gets rates for a daily-plus-hourly service_day' do
        service_day.total_time_in_care = 12.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (2.25 * nebraska_school_age_unaccredited_non_urban_hourly_rate.amount * (1.05**3)) +
          (1 * nebraska_school_age_unaccredited_non_urban_daily_rate.amount * (1.05**3))
        )
      end

      it 'gets rates for a service_day at the max of 18 hours' do
        service_day.total_time_in_care = 21.hours + 12.minutes
        expect(
          described_class.new(
            service_day: service_day,
            child_approvals: child_approvals,
            rates: rates
          ).earned_revenue
        ).to eq(
          (8 * nebraska_school_age_unaccredited_non_urban_hourly_rate.amount * (1.05**3)) +
          (1 * nebraska_school_age_unaccredited_non_urban_daily_rate.amount * (1.05**3))
        )
      end

      context 'with a special needs approved child' do
        before do
          child.child_approvals.first.update!(
            special_needs_rate: true,
            special_needs_daily_rate: 20.0,
            special_needs_hourly_rate: 5.60
          )
        end

        it 'gets rates for an hourly-only service_day' do
          service_day.total_time_in_care = 3.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(3.25 * child.child_approvals.first.special_needs_hourly_rate)
        end

        it 'gets rates for a daily-only service_day' do
          service_day.total_time_in_care = 6.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(1 * child.child_approvals.first.special_needs_daily_rate)
        end

        it 'gets rates for a daily-plus-hourly service_day' do
          service_day.total_time_in_care = 12.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (2.25 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end

        it 'gets rates for a service_day at the max of 18 hours' do
          service_day.total_time_in_care = 21.hours + 12.minutes
          expect(
            described_class.new(
              service_day: service_day,
              child_approvals: child_approvals,
              rates: rates
            ).earned_revenue
          ).to eq(
            (8 * child.child_approvals.first.special_needs_hourly_rate) +
            (1 * child.child_approvals.first.special_needs_daily_rate)
          )
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
