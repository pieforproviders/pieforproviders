# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlueprint do
  let(:user) { create(:user) }
  let(:last_month) { Time.current.in_time_zone(user.timezone).at_beginning_of_day - 1.month }
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
      let(:illinois_business) { create(:business, user: user) }

      before do
        create(:attendance,
               check_in: last_month,
               child_approval: create(:child, business: illinois_business).child_approvals.first)
        create(:child, :with_two_illinois_attendances, business: illinois_business)
      end

      it 'returns the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end

      it "returns the as_of date in the user's timezone" do
        blueprint = described_class.render(user, view: :illinois_dashboard)
        expect(JSON.parse(blueprint)['as_of'])
          .to eq(user.latest_service_day_in_month(Time.current).strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date for the last attendance in the prior month in Illinois' do
        attendance = create(:attendance, check_in: last_month)
        blueprint = described_class.render(user, view: :illinois_dashboard, filter_date: last_month.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date as today for a month with no attendances in Illinois' do
        blueprint = described_class.render(
          user,
          view: :illinois_dashboard,
          filter_date: last_month.at_end_of_month - 6.months
        )
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end

    context "when there are no approvals for this user's children" do
      it 'returns nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end

      it "returns the as_of date in the user's timezone" do
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end
  end

  context 'when NE view is requested' do
    let(:nebraska_business) { create(:business, :nebraska_ldds, user: user) }
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
      before do
        create(:attendance,
               check_in: last_month,
               child_approval: create(:child, business: nebraska_business).child_approvals.first)
        child = create(:child, business: nebraska_business)
        create_list(:attendance, 2, child_approval: child.child_approvals.first, check_in: Time.current)
      end

      it 'returns the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end

      it "returns the as_of date in the user's timezone" do
        blueprint = described_class.render(user, view: :nebraska_dashboard)
        expect(JSON.parse(blueprint)['as_of'])
          .to eq(user.latest_service_day_in_month(Time.current).strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date for the last attendance in the prior month' do
        attendance = create(:attendance, check_in: last_month)
        blueprint = described_class.render(user, view: :nebraska_dashboard, filter_date: last_month.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date as today for a month with no attendances' do
        blueprint = described_class.render(
          user,
          view: :nebraska_dashboard,
          filter_date: last_month.at_end_of_month - 6.months
        )
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end

    context "when there are no approvals for this user's children" do
      it 'returns nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end

      it "returns the as_of date in the user's timezone" do
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end
  end

  context 'when profile view is requested' do
    let(:blueprint) { described_class.render(user, view: :profile) }

    it 'includes user profile fields' do
      expect(parsed_response.keys).to contain_exactly(
        'full_name',
        'greeting_name',
        'phone_number',
        'email',
        'language',
        'businesses'
      )
    end

    context 'when there are businesses for this user' do
      before { create(:business, user: user) }

      it 'includes a list of associated businesses' do
        expect(parsed_response['businesses'].length).to eq(1)
      end
    end

    context 'when there are no businesses for this user' do
      it 'includes an empty array of businesses' do
        expect(parsed_response['businesses'].length).to eq(0)
      end
    end
  end
end
