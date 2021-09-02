# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlueprint do
  let(:user) { create(:user) }
  let(:blueprint) { UserBlueprint.render(user) }
  let(:parsed_response) { JSON.parse(blueprint) }

  context 'returns the correct fields when no view option is passed' do
    it 'only includes the expected user fields' do
      expect(parsed_response.keys).to contain_exactly(
        'greeting_name',
        'id',
        'language',
        'state'
      )
    end
  end

  context 'returns the correct fields when IL view is requested' do
    let(:blueprint) { UserBlueprint.render(user, view: :illinois_dashboard) }
    it 'includes IL dashboard fields' do
      expect(parsed_response.keys).to contain_exactly(
        'as_of',
        'businesses',
        'first_approval_effective_date'
      )
    end
    context "when there are approvals for this user's children" do
      let!(:illinois_business) { create(:business, user: user) }
      let!(:child) { create(:child, :with_two_illinois_attendances, business: illinois_business) }
      it 'displays the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end
    end
    context "when there are no approvals for this user's children" do
      it 'displays nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end
    end
  end

  context 'returns the correct fields when NE view is requested' do
    let(:blueprint) { UserBlueprint.render(user, view: :nebraska_dashboard) }
    it 'includes the user name and all cases' do
      expect(parsed_response.keys).to contain_exactly(
        'as_of',
        'first_approval_effective_date',
        'businesses',
        'max_revenue',
        'total_approved'
      )
      expect(parsed_response['max_revenue']).to eq('N/A')
      expect(parsed_response['total_approved']).to eq('N/A')
    end
    context "when there are approvals for this user's children" do
      let!(:nebraska_business) { create(:business, :nebraska, user: user) }
      let!(:child) { create(:necc_child, :with_two_nebraska_attendances, business: nebraska_business) }
      it 'displays the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end
    end
    context "when there are no approvals for this user's children" do
      it 'displays nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end
    end
  end

  context 'returns the correct as of date' do
    let(:last_month) { Time.now.in_time_zone(user.timezone).at_beginning_of_day - 1.month }
    before do
      create(:attendance, check_in: last_month, child_approval: create(:child_approval, child: create(:child, business: create(:business, user: user))))
    end
    context 'in nebraska' do
      it "returns the as_of date in the user's timezone" do
        travel_to Time.now.in_time_zone(user.timezone).at_end_of_day
        blueprint = UserBlueprint.render(user, view: :nebraska_dashboard)
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.now.in_time_zone(user.timezone).strftime('%m/%d/%Y'))
        travel_back
      end
      it 'returns the as_of date for the last attendance in the prior month' do
        attendance = create(:attendance, check_in: last_month)
        blueprint = UserBlueprint.render(user, view: :nebraska_dashboard, filter_date: last_month.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end
      it 'returns the as_of date as today for a month with no attendances' do
        blueprint = UserBlueprint.render(user, view: :nebraska_dashboard, filter_date: last_month.at_end_of_month - 6.months)
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.now.in_time_zone(user.timezone).strftime('%m/%d/%Y'))
      end
    end
    context 'in illinois' do
      it "returns the as_of date in the user's timezone" do
        travel_to Time.now.in_time_zone(user.timezone).at_end_of_day
        blueprint = UserBlueprint.render(user, view: :illinois_dashboard)
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.now.in_time_zone(user.timezone).strftime('%m/%d/%Y'))
        travel_back
      end
      it 'returns the as_of date for the last attendance in the prior month' do
        attendance = create(:attendance, check_in: last_month)
        blueprint = UserBlueprint.render(user, view: :illinois_dashboard, filter_date: last_month.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end
      it 'returns the as_of date as today for a month with no attendances' do
        blueprint = UserBlueprint.render(user, view: :nebraska_dashboard, filter_date: last_month.at_end_of_month - 6.months)
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.now.in_time_zone(user.timezone).strftime('%m/%d/%Y'))
      end
    end
  end
end
