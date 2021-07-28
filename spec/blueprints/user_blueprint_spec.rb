# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlueprint do
  let(:user) { create(:user) }
  let(:blueprint) { UserBlueprint.render(user) }
  context 'returns the correct fields when no view option is passed' do
    it 'only includes the ID' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
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
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'as_of',
        'businesses',
        'first_approval_effective_date'
      )
    end
  end
  context 'returns the correct fields when NE view is requested' do
    let(:blueprint) { UserBlueprint.render(user, view: :nebraska_dashboard) }
    it 'includes the user name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'as_of',
        'first_approval_effective_date',
        'businesses',
        'max_revenue',
        'total_approved'
      )
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
      end
      it 'returns the as_of date for the last attendance in the prior month' do
        attendance = create(:attendance, check_in: last_month)
        blueprint = UserBlueprint.render(user, view: :nebraska_dashboard, filter_date: last_month.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end
    end
    context 'in illinois' do
      it "returns the as_of date in the user's timezone" do
        travel_to Time.now.in_time_zone(user.timezone).at_end_of_day
        blueprint = UserBlueprint.render(user, view: :illinois_dashboard)
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.now.in_time_zone(user.timezone).strftime('%m/%d/%Y'))
      end
      it 'returns the as_of date for the last attendance in the prior month' do
        attendance = create(:attendance, check_in: last_month)
        blueprint = UserBlueprint.render(user, view: :illinois_dashboard, filter_date: last_month.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end
    end
  end
end
