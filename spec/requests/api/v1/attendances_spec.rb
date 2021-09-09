# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Attendances', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business)       { create(:business, user: logged_in_user) }
  let!(:child)          { create(:child, business: business) }

  let!(:week_mid_date)   { Time.new(2021, 9, 8).in_time_zone }  # Wed, 8th Sept, 2021
  let!(:week_start_date) { week_mid_date - 3.days }             # Sun, 5th Sept, 2021
  let!(:week_end_date)   { week_mid_date + 3.days }             # Sat, 11th Sept, 2021

  let!(:two_weeks_ago_week_mid_date)   { week_mid_date - 2.weeks }   # Wed, 25th Aug, 2021
  let!(:two_weeks_ago_week_start_date) { week_start_date - 2.weeks } # Sun, 22th Aug, 2021
  let!(:two_weeks_ago_week_end_date)   { week_end_date - 2.weeks }   # Sat, 28th Aug, 2021

  let!(:this_week_attendances) do
    check_in_date = Faker::Time.between(from: week_start_date, to: week_end_date)

    create_list(:attendance, 3, child_approval: child.child_approvals.first, check_in: check_in_date)
  end

  let!(:past_attendances) do
    check_in_date = Faker::Time.between(from: two_weeks_ago_week_start_date, to: two_weeks_ago_week_end_date)

    create_list(:attendance, 2, child_approval: child.child_approvals.first, check_in: check_in_date)
  end

  let!(:extra_attendances) do
    create_list(:attendance, 3, check_in: Faker::Time.between(from: week_start_date, to: week_mid_date))
  end

  describe 'GET /api/v1/attendances' do
    include_context 'correct api version header'

    before { sign_in logged_in_user }

    context 'when sent with a filter date' do
      let(:params) { { filter_date: two_weeks_ago_week_mid_date } }

      it 'displays the attendances' do
        get '/api/v1/attendances', params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['child_approval_id'] }).to match_array(past_attendances.collect(&:child_approval_id))
        expect(parsed_response.collect { |x| x['total_time_in_care'] }).to match_array(past_attendances.collect { |x| x.total_time_in_care.to_s })
        expect(parsed_response.length).to eq(2)
        expect(response).to match_response_schema('attendances')
      end
    end

    context 'when sent without a filter date' do
      it 'displays the attendances' do
        get '/api/v1/attendances', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['child_approval_id'] }).to match_array(this_week_attendances.collect(&:child_approval_id))
        expect(parsed_response.collect { |x| x['total_time_in_care'] }).to match_array(this_week_attendances.collect { |x| x.total_time_in_care.to_s })
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('attendances')
      end
    end

    context 'when viewed by an admin' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'displays the attendances' do
        get '/api/v1/attendances', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        all_current_attendances = this_week_attendances + extra_attendances
        expect(parsed_response.collect { |x| x['child_approval_id'] }).to match_array(all_current_attendances.collect(&:child_approval_id))
        expect(parsed_response.collect { |x| x['total_time_in_care'] }).to match_array(all_current_attendances.collect { |x| x.total_time_in_care.to_s })
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('attendances')
      end
    end
  end
end
