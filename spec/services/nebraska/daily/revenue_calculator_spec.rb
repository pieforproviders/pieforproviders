# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nebraska::Daily::RevenueCalculator, type: :service do
  let!(:full_day_ldds_rate) do
    create(:unaccredited_daily_ldds_rate, max_age: 216, effective_on: 3.months.ago, expires_on: nil)
  end
  let!(:hourly_ldds_rate) do
    create(:unaccredited_hourly_ldds_rate, max_age: 216, effective_on: 3.months.ago, expires_on: nil)
  end
  let!(:full_day_other_rate) do
    create(:unaccredited_daily_other_region_rate, max_age: 216, effective_on: 3.months.ago, expires_on: nil)
  end
  let!(:hourly_other_rate) do
    create(:unaccredited_hourly_other_region_rate, max_age: 216, effective_on: 3.months.ago, expires_on: nil)
  end
  let!(:full_day_ld_license_exempt_rate) do
    create(:nebraska_rate,
           :license_exempt_home_ld,
           :daily,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:hourly_ld_license_exempt_rate) do
    create(:nebraska_rate,
           :license_exempt_home_ld,
           :hourly,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:full_day_ds_license_exempt_rate) do
    create(:nebraska_rate,
           :license_exempt_home_ds,
           :daily,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:hourly_ds_license_exempt_rate) do
    create(:nebraska_rate,
           :license_exempt_home_ds,
           :hourly,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:full_day_other_license_exempt_rate) do
    create(:nebraska_rate,
           :license_exempt_home_other,
           :daily,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:hourly_other_license_exempt_rate) do
    create(:nebraska_rate,
           :license_exempt_home_other,
           :hourly,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:full_day_fih_rate) do
    create(:nebraska_rate,
           :family_in_home,
           :daily,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:hourly_fih_rate) do
    create(:nebraska_rate,
           :family_in_home,
           :hourly,
           max_age: 216,
           effective_on: 3.months.ago,
           expires_on: nil)
  end
  let!(:business_ldds) { create(:business, :nebraska_ldds, :unaccredited, :step_four) }
  let!(:child_ldds) { create(:necc_child, business: business_ldds, effective_date: 1.month.ago) }
  let!(:child_ldds_child_approval) { child_ldds.child_approvals.first }
  let!(:business_other) { create(:business, :nebraska_other, :unaccredited, :step_four) }
  let!(:child_other) { create(:necc_child, business: business_other, effective_date: 1.month.ago) }
  let!(:child_other_child_approval) { child_other.child_approvals.first }
  let!(:business_license_exempt_ld) { create(:business, :nebraska_license_exempt_home_ld, :unaccredited, :not_rated) }
  let!(:child_license_exempt_ld) do
    create(:necc_child, business: business_license_exempt_ld, effective_date: 1.month.ago)
  end
  let!(:child_license_exempt_ld_child_approval) { child_license_exempt_ld.child_approvals.first }
  let!(:business_license_exempt_ds) { create(:business, :nebraska_license_exempt_home_ds, :unaccredited, :not_rated) }
  let!(:child_license_exempt_ds) do
    create(:necc_child, business: business_license_exempt_ds, effective_date: 1.month.ago)
  end
  let!(:child_license_exempt_ds_child_approval) { child_license_exempt_ds.child_approvals.first }
  let!(:business_license_exempt_other) do
    create(:business, :nebraska_license_exempt_home_other, :unaccredited, :not_rated)
  end
  let!(:child_license_exempt_other) do
    create(:necc_child, business: business_license_exempt_other, effective_date: 1.month.ago)
  end
  let!(:child_license_exempt_other_child_approval) { child_license_exempt_other.child_approvals.first }
  let!(:business_fih) { create(:business, :nebraska_family_in_home, :unaccredited, :not_rated) }
  let!(:child_fih) { create(:necc_child, business: business_fih, effective_date: 1.month.ago) }
  let!(:child_fih_child_approval) { child_fih.child_approvals.first }

  describe '#call' do
    context 'with a child who has a special needs rate' do
      it 'uses the special needs rate defined on their approval letter instead of the state rates' do
        child_ldds_child_approval.update!(
          special_needs_rate: true,
          special_needs_daily_rate: 25.00,
          special_needs_hourly_rate: 3.00
        )

        expect(
          described_class.new(
            child_approval: child_ldds_child_approval,
            date: child_ldds_child_approval.effective_on,
            total_time_in_care: 3.hours + 23.minutes,
            rates: NebraskaRate.for_case(
              child_ldds_child_approval.effective_on,
              child_ldds_child_approval&.enrolled_in_school || false,
              child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
              business_ldds
            )
          ).call
        ).to eq(child_ldds_child_approval.special_needs_hourly_rate * 3.5)

        expect(
          described_class.new(
            child_approval: child_ldds_child_approval,
            date: child_ldds_child_approval.effective_on,
            total_time_in_care: 8.hours + 11.minutes,
            rates: NebraskaRate.for_case(
              child_ldds_child_approval.effective_on,
              child_ldds_child_approval&.enrolled_in_school || false,
              child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
              business_ldds
            )
          ).call
        ).to eq(child_ldds_child_approval.special_needs_daily_rate * 1)

        expect(
          described_class.new(
            child_approval: child_ldds_child_approval,
            date: child_ldds_child_approval.effective_on,
            total_time_in_care: 13.hours + 10.minutes,
            rates: NebraskaRate.for_case(
              child_ldds_child_approval.effective_on,
              child_ldds_child_approval&.enrolled_in_school || false,
              child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
              business_ldds
            )
          ).call
        ).to eq(
          (child_ldds_child_approval.special_needs_daily_rate * 1) +
          (child_ldds_child_approval.special_needs_hourly_rate * 3.25)
        )

        expect(
          described_class.new(
            child_approval: child_ldds_child_approval,
            date: child_ldds_child_approval.effective_on,
            total_time_in_care: 19.hours + 52.minutes,
            rates: NebraskaRate.for_case(
              child_ldds_child_approval.effective_on,
              child_ldds_child_approval&.enrolled_in_school || false,
              child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
              business_ldds
            )
          ).call
        ).to eq(
          (child_ldds_child_approval.special_needs_daily_rate * 1) +
          (child_ldds_child_approval.special_needs_hourly_rate * 8)
        )
      end
    end

    it 'calculates the correct revenue for an hourly attendance' do
      expect(
        described_class.new(
          child_approval: child_ldds_child_approval,
          date: child_ldds_child_approval.effective_on,
          total_time_in_care: 3.hours + 23.minutes,
          rates: NebraskaRate.for_case(
            child_ldds_child_approval.effective_on,
            child_ldds_child_approval&.enrolled_in_school || false,
            child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
            business_ldds
          )
        ).call
      ).to eq(hourly_ldds_rate.amount * 3.5 * business_ldds.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_other_child_approval,
          date: child_other_child_approval.effective_on,
          total_time_in_care: 3.hours + 23.minutes,
          rates: NebraskaRate.for_case(
            child_other_child_approval.effective_on,
            child_other_child_approval&.enrolled_in_school || false,
            child_other&.age_in_months(child_other_child_approval.effective_on),
            business_other
          )
        ).call
      ).to eq(hourly_other_rate.amount * 3.5 * business_other.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_license_exempt_ld_child_approval,
          date: child_license_exempt_ld_child_approval.effective_on,
          total_time_in_care: 3.hours + 23.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ld_child_approval.effective_on,
            child_license_exempt_ld_child_approval&.enrolled_in_school || false,
            child_license_exempt_ld&.age_in_months(child_license_exempt_ld_child_approval.effective_on),
            business_license_exempt_ld
          )
        ).call
      ).to eq(hourly_ld_license_exempt_rate.amount * 3.5 * business_license_exempt_ld.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_license_exempt_ds_child_approval,
          date: child_license_exempt_ds_child_approval.effective_on,
          total_time_in_care: 3.hours + 23.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ds_child_approval.effective_on,
            child_license_exempt_ds_child_approval&.enrolled_in_school || false,
            child_license_exempt_ds&.age_in_months(child_license_exempt_ds_child_approval.effective_on),
            business_license_exempt_ds
          )
        ).call
      ).to eq(hourly_ds_license_exempt_rate.amount * 3.5 * business_license_exempt_ds.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_license_exempt_other_child_approval,
          date: child_license_exempt_other_child_approval.effective_on,
          total_time_in_care: 3.hours + 23.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_other_child_approval.effective_on,
            child_license_exempt_other_child_approval&.enrolled_in_school || false,
            child_license_exempt_other&.age_in_months(child_license_exempt_other_child_approval.effective_on),
            business_license_exempt_other
          )
        ).call
      ).to eq(hourly_other_license_exempt_rate.amount * 3.5 * business_license_exempt_other.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_fih_child_approval,
          date: child_fih_child_approval.effective_on,
          total_time_in_care: 3.hours + 23.minutes,
          rates: NebraskaRate.for_case(
            child_fih_child_approval.effective_on,
            child_fih_child_approval&.enrolled_in_school || false,
            child_fih&.age_in_months(child_fih_child_approval.effective_on),
            business_fih
          )
        ).call
      ).to eq(hourly_fih_rate.amount * 3.5 * business_fih.ne_qris_bump)
    end

    it 'calculates the correct revenue for a daily attendance' do
      expect(
        described_class.new(
          child_approval: child_ldds_child_approval,
          date: child_ldds_child_approval.effective_on,
          total_time_in_care: 8.hours + 11.minutes,
          rates: NebraskaRate.for_case(
            child_ldds_child_approval.effective_on,
            child_ldds_child_approval&.enrolled_in_school || false,
            child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
            business_ldds
          )
        ).call
      ).to eq(full_day_ldds_rate.amount * 1 * business_ldds.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_other_child_approval,
          date: child_other_child_approval.effective_on,
          total_time_in_care: 8.hours + 11.minutes,
          rates: NebraskaRate.for_case(
            child_other_child_approval.effective_on,
            child_other_child_approval&.enrolled_in_school || false,
            child_other&.age_in_months(child_other_child_approval.effective_on),
            business_other
          )
        ).call
      ).to eq(full_day_other_rate.amount * 1 * business_other.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_license_exempt_ld_child_approval,
          date: child_license_exempt_ld_child_approval.effective_on,
          total_time_in_care: 8.hours + 11.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ld_child_approval.effective_on,
            child_license_exempt_ld_child_approval&.enrolled_in_school || false,
            child_license_exempt_ld&.age_in_months(child_license_exempt_ld_child_approval.effective_on),
            business_license_exempt_ld
          )
        ).call
      ).to eq(full_day_ld_license_exempt_rate.amount * 1 * business_license_exempt_ld.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_license_exempt_ds_child_approval,
          date: child_license_exempt_ds_child_approval.effective_on,
          total_time_in_care: 8.hours + 11.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ds_child_approval.effective_on,
            child_license_exempt_ds_child_approval&.enrolled_in_school || false,
            child_license_exempt_ds&.age_in_months(child_license_exempt_ds_child_approval.effective_on),
            business_license_exempt_ds
          )
        ).call
      ).to eq(full_day_ds_license_exempt_rate.amount * 1 * business_license_exempt_ds.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_license_exempt_other_child_approval,
          date: child_license_exempt_other_child_approval.effective_on,
          total_time_in_care: 8.hours + 11.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_other_child_approval.effective_on,
            child_license_exempt_other_child_approval&.enrolled_in_school || false,
            child_license_exempt_other&.age_in_months(child_license_exempt_other_child_approval.effective_on),
            business_license_exempt_other
          )
        ).call
      ).to eq(full_day_other_license_exempt_rate.amount * 1 * business_license_exempt_other.ne_qris_bump)

      expect(
        described_class.new(
          child_approval: child_fih_child_approval,
          date: child_fih_child_approval.effective_on,
          total_time_in_care: 8.hours + 11.minutes,
          rates: NebraskaRate.for_case(
            child_fih_child_approval.effective_on,
            child_fih_child_approval&.enrolled_in_school || false,
            child_fih&.age_in_months(child_fih_child_approval.effective_on),
            business_fih
          )
        ).call
      ).to eq(full_day_fih_rate.amount * 1 * business_fih.ne_qris_bump)
    end

    it 'calculates the correct revenue for a daily_plus_hourly attendance' do
      expect(
        described_class.new(
          child_approval: child_ldds_child_approval,
          date: child_ldds_child_approval.effective_on,
          total_time_in_care: 13.hours + 10.minutes,
          rates: NebraskaRate.for_case(
            child_ldds_child_approval.effective_on,
            child_ldds_child_approval&.enrolled_in_school || false,
            child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
            business_ldds
          )
        ).call
      ).to eq(
        (full_day_ldds_rate.amount * 1 * business_ldds.ne_qris_bump) +
        (hourly_ldds_rate.amount * 3.25 * business_ldds.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_other_child_approval,
          date: child_other_child_approval.effective_on,
          total_time_in_care: 13.hours + 10.minutes,
          rates: NebraskaRate.for_case(
            child_other_child_approval.effective_on,
            child_other_child_approval&.enrolled_in_school || false,
            child_other&.age_in_months(child_other_child_approval.effective_on),
            business_other
          )
        ).call
      ).to eq(
        (full_day_other_rate.amount * 1 * business_other.ne_qris_bump) +
        (hourly_other_rate.amount * 3.25 * business_other.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_license_exempt_ld_child_approval,
          date: child_license_exempt_ld_child_approval.effective_on,
          total_time_in_care: 13.hours + 10.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ld_child_approval.effective_on,
            child_license_exempt_ld_child_approval&.enrolled_in_school || false,
            child_license_exempt_ld&.age_in_months(child_license_exempt_ld_child_approval.effective_on),
            business_license_exempt_ld
          )
        ).call
      ).to eq(
        (full_day_ld_license_exempt_rate.amount * 1 * business_license_exempt_ld.ne_qris_bump) +
        (hourly_ld_license_exempt_rate.amount * 3.25 * business_license_exempt_ld.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_license_exempt_ds_child_approval,
          date: child_license_exempt_ds_child_approval.effective_on,
          total_time_in_care: 13.hours + 10.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ds_child_approval.effective_on,
            child_license_exempt_ds_child_approval&.enrolled_in_school || false,
            child_license_exempt_ds&.age_in_months(child_license_exempt_ds_child_approval.effective_on),
            business_license_exempt_ds
          )
        ).call
      ).to eq(
        (full_day_ds_license_exempt_rate.amount * 1 * business_license_exempt_ds.ne_qris_bump) +
        (hourly_ds_license_exempt_rate.amount * 3.25 * business_license_exempt_ds.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_license_exempt_other_child_approval,
          date: child_license_exempt_other_child_approval.effective_on,
          total_time_in_care: 13.hours + 10.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_other_child_approval.effective_on,
            child_license_exempt_other_child_approval&.enrolled_in_school || false,
            child_license_exempt_other&.age_in_months(child_license_exempt_other_child_approval.effective_on),
            business_license_exempt_other
          )
        ).call
      ).to eq(
        (full_day_other_license_exempt_rate.amount * 1 * business_license_exempt_other.ne_qris_bump) +
        (hourly_other_license_exempt_rate.amount * 3.25 * business_license_exempt_other.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_fih_child_approval,
          date: child_fih_child_approval.effective_on,
          total_time_in_care: 13.hours + 10.minutes,
          rates: NebraskaRate.for_case(
            child_fih_child_approval.effective_on,
            child_fih_child_approval&.enrolled_in_school || false,
            child_fih&.age_in_months(child_fih_child_approval.effective_on),
            business_fih
          )
        ).call
      ).to eq(
        (full_day_fih_rate.amount * 1 * business_fih.ne_qris_bump) +
        (hourly_fih_rate.amount * 3.25 * business_fih.ne_qris_bump)
      )
    end

    it 'calculates the correct revenue for a daily_plus_hourly_max attendance' do
      expect(
        described_class.new(
          child_approval: child_ldds_child_approval,
          date: child_ldds_child_approval.effective_on,
          total_time_in_care: 19.hours + 52.minutes,
          rates: NebraskaRate.for_case(
            child_ldds_child_approval.effective_on,
            child_ldds_child_approval&.enrolled_in_school || false,
            child_ldds&.age_in_months(child_ldds_child_approval.effective_on),
            business_ldds
          )
        ).call
      ).to eq(
        (full_day_ldds_rate.amount * 1 * business_ldds.ne_qris_bump) +
        (hourly_ldds_rate.amount * 8 * business_ldds.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_other_child_approval,
          date: child_other_child_approval.effective_on,
          total_time_in_care: 19.hours + 52.minutes,
          rates: NebraskaRate.for_case(
            child_other_child_approval.effective_on,
            child_other_child_approval&.enrolled_in_school || false,
            child_other&.age_in_months(child_other_child_approval.effective_on),
            business_other
          )
        ).call
      ).to eq(
        (full_day_other_rate.amount * 1 * business_other.ne_qris_bump) +
        (hourly_other_rate.amount * 8 * business_other.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_license_exempt_ld_child_approval,
          date: child_license_exempt_ld_child_approval.effective_on,
          total_time_in_care: 19.hours + 52.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ld_child_approval.effective_on,
            child_license_exempt_ld_child_approval&.enrolled_in_school || false,
            child_license_exempt_ld&.age_in_months(child_license_exempt_ld_child_approval.effective_on),
            business_license_exempt_ld
          )
        ).call
      ).to eq(
        (full_day_ld_license_exempt_rate.amount * 1 * business_license_exempt_ld.ne_qris_bump) +
        (hourly_ld_license_exempt_rate.amount * 8 * business_license_exempt_ld.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_license_exempt_ds_child_approval,
          date: child_license_exempt_ds_child_approval.effective_on,
          total_time_in_care: 19.hours + 52.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_ds_child_approval.effective_on,
            child_license_exempt_ds_child_approval&.enrolled_in_school || false,
            child_license_exempt_ds&.age_in_months(child_license_exempt_ds_child_approval.effective_on),
            business_license_exempt_ds
          )
        ).call
      ).to eq(
        (full_day_ds_license_exempt_rate.amount * 1 * business_license_exempt_ds.ne_qris_bump) +
        (hourly_ds_license_exempt_rate.amount * 8 * business_license_exempt_ds.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_license_exempt_other_child_approval,
          date: child_license_exempt_other_child_approval.effective_on,
          total_time_in_care: 19.hours + 52.minutes,
          rates: NebraskaRate.for_case(
            child_license_exempt_other_child_approval.effective_on,
            child_license_exempt_other_child_approval&.enrolled_in_school || false,
            child_license_exempt_other&.age_in_months(child_license_exempt_other_child_approval.effective_on),
            business_license_exempt_other
          )
        ).call
      ).to eq(
        (full_day_other_license_exempt_rate.amount * 1 * business_license_exempt_other.ne_qris_bump) +
        (hourly_other_license_exempt_rate.amount * 8 * business_license_exempt_other.ne_qris_bump)
      )

      expect(
        described_class.new(
          child_approval: child_fih_child_approval,
          date: child_fih_child_approval.effective_on,
          total_time_in_care: 19.hours + 52.minutes,
          rates: NebraskaRate.for_case(
            child_fih_child_approval.effective_on,
            child_fih_child_approval&.enrolled_in_school || false,
            child_fih&.age_in_months(child_fih_child_approval.effective_on),
            business_fih
          )
        ).call
      ).to eq(
        (full_day_fih_rate.amount * 1 * business_fih.ne_qris_bump) +
        (hourly_fih_rate.amount * 8 * business_fih.ne_qris_bump)
      )
    end
  end
end
