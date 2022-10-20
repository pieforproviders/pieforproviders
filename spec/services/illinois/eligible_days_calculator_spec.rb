# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::EligibleDaysCalculator do
  before { travel_to '2022-10-01'.to_date }

  describe 'calculate eligible days without holidays' do
    let(:child) { create(:child_in_illinois) }

    it 'returns eligible full days for a child in a given month' do
      weeks_in_october = DateService.weeks_in_month(Time.current)
      approval_record_in_november = child
                                    .illinois_approval_amounts
                                    .where("month between '2022-10-01' AND '2022-10-31'")
                                    .first
      eligible_days_by_month = approval_record_in_november.full_days_approved_per_week * weeks_in_october
      expect(child.eligible_full_days_by_month(Time.current.to_date)).to eq(eligible_days_by_month)
    end

    it 'returns eligible part days for a child in a given month' do
      weeks_in_october = DateService.weeks_in_month(Time.current)
      approval_record_in_november = child
                                    .illinois_approval_amounts
                                    .where("month between '2022-11-01' AND '2022-11-30'")
                                    .first
      eligible_days_by_month = approval_record_in_november.part_days_approved_per_week * weeks_in_october

      expect(child.eligible_part_days_by_month(Time.current.to_date)).to eq(eligible_days_by_month)
    end
  end

  describe '#calculate eligible days with holidays' do
    let(:business) { create(:business) }
    let(:child) { create(:child_in_illinois, business: business) }
    let(:holiday) { create(:holiday) }

    it 'returns eligible full days for a child in a month with holiday' do
      november = Date.new(2022, 12, 1)
      weeks_in_november = DateService.weeks_in_month(november)
      approval_record_in_november = child
                                    .illinois_approval_amounts
                                    .where("month between '2022-12-01' AND '2022-12-31'")
                                    .first
      eligible_days_by_month = approval_record_in_november.full_days_approved_per_week * weeks_in_november
      expect(child.eligible_full_days_by_month(november)).to eq(eligible_days_by_month)
    end

    it 'returns eligible part days for a child in a month with holiday' do
      november = Date.new(2022, 12, 1)
      weeks_in_november = DateService.weeks_in_month(november)
      approval_record_in_november = child
                                    .illinois_approval_amounts
                                    .where("month between '2022-12-01' AND '2022-12-31'")
                                    .first
      eligible_days_by_month = approval_record_in_november.part_days_approved_per_week * weeks_in_november
      expect(child.eligible_part_days_by_month(november)).to eq(eligible_days_by_month)
    end
  end

  describe '#calculate eligible days with closed days' do
    let(:business) { create(:business_with_closed_days_in_november) }
    let(:child) { create(:child_in_illinois, business: business) }

    it 'returns eligible full days for a child in a month with closures' do
      november = Date.new(2022, 11, 1)
      weeks_in_november = DateService.weeks_in_month(november)
      approval_record_in_november = child
                                    .illinois_approval_amounts
                                    .where("month between '2022-11-01' AND '2022-11-30'")
                                    .first
      eligible_days_by_month = approval_record_in_november.full_days_approved_per_week * weeks_in_november
      expect(child.eligible_full_days_by_month(november)).to be <= eligible_days_by_month
    end

    it 'returns eligible part days for a child in a month with closures' do
      november = Date.new(2022, 12, 1)
      weeks_in_november = DateService.weeks_in_month(november)
      approval_record_in_november = child
                                    .illinois_approval_amounts
                                    .where("month between '2022-12-01' AND '2022-12-31'")
                                    .first
      eligible_days_by_month = approval_record_in_november.part_days_approved_per_week * weeks_in_november
      expect(child.eligible_part_days_by_month(november)).to be <= eligible_days_by_month
    end
  end
end
