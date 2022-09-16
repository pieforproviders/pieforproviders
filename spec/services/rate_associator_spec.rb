# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateAssociator do
  let!(:date) { Time.current }
  let!(:illinois_rate_cook_age5) { create(:illinois_rate, region: 'group_1a', age_bucket: 5) }
  let!(:illinois_rate_cook_age3) { create(:illinois_rate, region: 'group_1a', age_bucket: 3) }
  let!(:illinois_rate_champaign) { create(:illinois_rate, region: 'group_1b', age_bucket: 12) }
  let!(:business_cook) { create(:business, county: 'Cook', zipcode: '60606') }
  let!(:business_champaign) { create(:business, county: 'Champaign', zipcode: '60613') }
  let(:child_cook) { build(:child, date_of_birth: date - 2.years - 3.weeks, business: business_cook) }

  after do
    clear_enqueued_jobs
  end

  it 'associates a rate on creation' do
    perform_enqueued_jobs do
      child_cook.save!
    end
    expect(child_cook.active_rate(date)).to eq(illinois_rate_cook_age3)
  end

  it 'associates a rate on update' do
    too_old_for_cook = child_cook.date_of_birth - 4.years - 3.months
    perform_enqueued_jobs do
      child_cook.update!(date_of_birth: too_old_for_cook)
    end
    expect(child_cook.active_rate(date)).to be_nil
    perform_enqueued_jobs do
      child_cook.update!(date_of_birth: too_old_for_cook + 2.years + 2.months)
    end
    expect(child_cook.active_rate(date)).to eq(illinois_rate_cook_age5)
    age_eligible_for_champaign = date - 6.years - 3.months
    perform_enqueued_jobs do
      child_cook.update!(business: business_champaign, date_of_birth: age_eligible_for_champaign)
    end
    expect(child_cook.active_rate(date)).to eq(illinois_rate_champaign)
  end
end
