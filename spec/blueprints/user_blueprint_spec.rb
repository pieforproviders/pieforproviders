# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlueprint do
  let(:user) { create(:user) }
  let(:blueprint) { described_class.render(user) }
  let(:parsed_response) { JSON.parse(blueprint) }

  it 'only includes the expected user fields' do
    expect(parsed_response.keys).to contain_exactly(
      'greeting_name',
      'id',
      'language',
      'state'
    )
  end

  context 'when IL view is requested' do
    let(:blueprint) { described_class.render(user, view: :illinois_dashboard) }

    it 'includes IL dashboard fields' do
      expect(parsed_response.keys).to contain_exactly(
        'as_of',
        'businesses',
        'first_approval_effective_date'
      )
    end

    context "when there are approvals for this user's children" do
      let!(:illinois_business) { create(:business, user: user) }

      before { create(:child, :with_two_illinois_attendances, business: illinois_business) }

      it 'returns the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end
    end

    context "when there are no approvals for this user's children" do
      it 'returns nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end
    end
  end

  context 'when NE view is requested' do
    let(:blueprint) { described_class.render(user, view: :nebraska_dashboard) }

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
      let!(:nebraska_business) { create(:business, :nebraska_ldds, user: user) }

      before { create(:necc_child, :with_two_nebraska_attendances, business: nebraska_business) }

      it 'returns the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end
    end

    context "when there are no approvals for this user's children" do
      it 'returns nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end
    end
  end

  context 'when an attendance is present' do
    let(:last_month) { Time.current.in_time_zone(user.timezone).at_beginning_of_day - 1.month }

    before do
      create(:attendance,
             check_in: last_month,
             child_approval: create(:child, business: create(:business, user: user)).child_approvals.first)
    end

    it "returns the as_of date in the user's timezone" do
      travel_to Time.current.at_end_of_day
      blueprint = described_class.render(user, view: :illinois_dashboard)
      expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))

      blueprint = described_class.render(user, view: :nebraska_dashboard)
      expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      travel_back
    end

    it 'returns the as_of date for the last attendance in the prior month in Illinois' do
      attendance = create(:attendance, check_in: last_month)
      blueprint = described_class.render(user, view: :illinois_dashboard, filter_date: last_month.at_end_of_month)
      expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))

      blueprint = described_class.render(user, view: :nebraska_dashboard, filter_date: last_month.at_end_of_month)
      expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
    end

    it 'returns the as_of date as today for a month with no attendances in Illinois' do
      blueprint = described_class.render(
        user,
        view: :nebraska_dashboard,
        filter_date: last_month.at_end_of_month - 6.months
      )
      expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))

      blueprint = described_class.render(
        user,
        view: :nebraska_dashboard,
        filter_date: last_month.at_end_of_month - 6.months
      )
      expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
    end
  end
end
