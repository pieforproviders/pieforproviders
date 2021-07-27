# frozen_string_literal: true

RSpec.describe 'Api::V1::Attendances', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business) { create(:business, user: logged_in_user) }
  let!(:child) { create(:child, business: business) }
  let!(:this_week_attendances) do
    create_list(:attendance, 3, child_approval: child.child_approvals.first, check_in: Faker::Time.between(from: Time.current.at_beginning_of_week, to: Time.current))
  end
  let!(:past_attendances) do
    create_list(:attendance, 2, child_approval: child.child_approvals.first,
                                check_in: Faker::Time.between(from: (Time.current - 2.weeks).at_beginning_of_week, to: (Time.current - 2.weeks).at_end_of_week))
  end
  let!(:extra_attendances) { create_list(:attendance, 3, check_in: Faker::Time.between(from: Time.current.at_beginning_of_week, to: Time.current)) }

  describe 'GET /api/v1/attendances' do
    include_context 'correct api version header'

    before do
      sign_in logged_in_user
    end

    context 'when sent with a filter date' do
      let(:params) { { filter_date: Time.zone.today - 2.weeks } }
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
