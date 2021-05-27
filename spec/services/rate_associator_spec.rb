# frozen_string_literal: true

require 'rails_helper'
# xcontext 'associates the record with a subsidy rule' do
#   let!(:date) { Time.current }
#   let!(:illinois_rate_cook_age5) { create(:illinois_rate, max_age: 5) }
#   let!(:illinois_rate_cook_age3) { create(:illinois_rate, max_age: 3) }
#   let!(:illinois_rate_dupage) { create(:illinois_rate, county: 'DuPage', max_age: 12) }
#   let!(:business_cook) { create(:business, county: 'Cook', zipcode: '60606') }
#   let!(:business_dupage) { create(:business, county: 'DuPage', zipcode: '60613') }
#   let(:child_cook) { build(:child, date_of_birth: date - 2.years - 3.weeks, business: business_cook) }

#   after do
#     clear_enqueued_jobs
#   end

#   it 'on creation' do
#     perform_enqueued_jobs do
#       child_cook.save!
#     end
#     expect(child_cook.active_rate(date)).to eq(illinois_rate_cook_age3)
#   end

#   it 'on update' do
#     too_old_for_cook = child_cook.date_of_birth - 4.years - 3.months
#     perform_enqueued_jobs do
#       child_cook.update!(date_of_birth: too_old_for_cook)
#     end
#     expect(child_cook.active_rate(date)).to be_nil
#     perform_enqueued_jobs do
#       child_cook.update!(date_of_birth: too_old_for_cook + 2.years + 2.months)
#     end
#     expect(child_cook.active_rate(date)).to eq(illinois_rate_cook_age5)
#     age_eligible_for_dupage = date - 6.years - 3.months
#     perform_enqueued_jobs do
#       child_cook.update!(business: business_dupage, date_of_birth: age_eligible_for_dupage)
#     end
#     expect(child_cook.active_rate(date)).to eq(illinois_rate_dupage)
#   end
# end
