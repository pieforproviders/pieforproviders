# frozen_string_literal: true

require 'rails_helper'

# Since the for_week scope on attendance model uses the Sunday to Friday week range, we should make
# sure we don't work with a Saturday date to avoid flakiness in spec runs. A way to do this is to set
# the week_current_date value to a day that falls within the expected week range

RSpec.describe 'Api::V1::Attendances', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business) { create(:business, user: logged_in_user) }
  let!(:child) { create(:child, business: business) }

  let!(:week_current_date) { Time.zone.local(2021, 9, 15) } # Wednesday
  let!(:week_start_date) { week_current_date.at_beginning_of_week(:sunday) } # Sunday
  let!(:week_end_date) { week_current_date.at_end_of_week(:saturday) } # Friday

  let!(:two_weeks_ago_week_current_date) { week_current_date - 2.weeks }
  let!(:two_weeks_ago_week_start_date) { week_start_date - 2.weeks }
  let!(:two_weeks_ago_week_end_date) { week_end_date - 2.weeks }

  let!(:this_week_attendances) do
    check_in_date = Faker::Time.between(from: week_start_date, to: week_end_date)

    create_list(:attendance, 3, child_approval: child.child_approvals.first, check_in: check_in_date)
  end

  let!(:past_attendances) do
    check_in_date = Faker::Time.between(from: two_weeks_ago_week_start_date, to: two_weeks_ago_week_end_date)

    create_list(:attendance, 2, child_approval: child.child_approvals.first, check_in: check_in_date)
  end

  let!(:extra_attendances) do
    create_list(:attendance, 3, check_in: Faker::Time.between(from: week_start_date, to: week_current_date))
  end

  describe 'GET /api/v1/attendances' do
    include_context 'correct api version header'

    before { sign_in logged_in_user }

    context 'when sent with a filter date' do
      let(:params) { { filter_date: two_weeks_ago_week_current_date } }

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
