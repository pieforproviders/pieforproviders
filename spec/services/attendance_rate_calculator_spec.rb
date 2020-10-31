# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceRateCalculator do
  context 'in Illinois' do
    let(:zipcode) { create(:zipcode, state: State.find_or_create!(abbr: 'IL', name: 'Illinois')) }
    let(:business) { create(:business, zipcode: zipcode, county: zipcode.county) }
    let(:business2) { create(:business, zipcode: zipcode, county: zipcode.county) }
    let(:child) { create(:child, business: business) }
    let(:child2) { create(:child2, business: business2) }
    let(:child3) { create(:child2, business: business2) }

    ## Create Subsidy Rules that apply to these children
    ## Add Rate Types for the attendances

    context 'with a family with one child' do
      before do
        # travel to July 12th, 2020
        travel_to Date.new(2020, 7, 12).at_end_of_day
        current_approval = child.approvals.where('expires_on > ? AND effective_on <= ?', Time.zone.today, Time.zone.today).child_approval
        # make 3 attendances from July 1st, 2020 to July 12th, 2020
        create_list(:billable_attendance, 3, child_approval: current_approval, date: Faker::Date.between(from: Time.zone.today.at_beginning_of_month, to: Time.zone.today - 1))
      end
      it 'returns the attendance rate' do
        result = AttendanceRateCalculator.new([child])
        # The child will have attended 3 out of 12 days, for 25% attendance
        expect(result).to eq(0.25)
      end
    end
  end
end
