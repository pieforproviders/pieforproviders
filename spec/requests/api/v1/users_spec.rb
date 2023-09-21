# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users' do
  # Do not send any emails (no confirmation emails, no password was changed emails)
  let(:user) { instance_double(User) }
  let!(:illinois_user) { create(:confirmed_user) }
  let!(:nebraska_user) { create(:confirmed_user, :nebraska) }
  let!(:nebraska_business) { create(:business, :nebraska_ldds, user: nebraska_user) }
  let!(:admin_user) { create(:confirmed_user, admin: true) }

  before do
    allow(user).to receive_messages(
      send_confirmation_notification?: false,
      send_password_change_notification?: false
    )
  end

  describe 'PUT /api/v1/users/::id' do
    include_context 'with correct api version header'
    context 'when logged in as non admin' do
      before { sign_in illinois_user }

      it 'updates the user' do
        put("/api/v1/users/#{illinois_user.id}", params: { user: { greeting_name: 'Harvey' } }, headers:)
        expect(response).to match_response_schema('user')
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq('Harvey')
      end

      it 'returns error if user is not within the scope of the user' do
        admin = create(:admin)
        put("/api/v1/users/#{admin.id}", params: { user: { full_name: 'Harvey Dent' } }, headers:)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as admin' do
      before { sign_in admin_user }

      it 'updates the user' do
        put("/api/v1/users/#{admin_user.id}", params: { user: { greeting_name: 'Harvey' } }, headers:)
        expect(response).to match_response_schema('user')
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq('Harvey')
      end

      it 'can update any user' do
        dummy = create(:confirmed_user)
        put("/api/v1/users/#{dummy.id}", params: { user: { greeting_name: 'Harvey' } }, headers:)
        expect(response).to match_response_schema('user')
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq('Harvey')
      end
    end
  end

  describe 'POST /api/v1/users' do
    include_context 'with correct api version header'

    context 'when logged in as admin' do
      before { sign_in admin_user }

      it 'creates a new user' do
        params =
          { user: { email: 'nebraska@test.com',
                    active: true,
                    full_name: 'Nebraska Provider',
                    greeting_name: 'Candice',
                    language: 'en',
                    opt_in_email: true,
                    opt_in_text: true,
                    phone_number: '777-666-5555',
                    state: 'NE',
                    get_from_pie: 'fame',
                    organization: 'Nebraska Child Care',
                    password: 'testpass1234!',
                    password_confirmation: 'testpass1234!',
                    service_agreement_accepted: true,
                    timezone: 'Mountain Time (US & Canada)',
                    stressed_about_billing: 'True',
                    accept_more_subsidy_families: 'True',
                    not_as_much_money: 'True',
                    too_much_time: 'True' } }
        post('/api/v1/users', params:, headers:)
        expect(response).to match_response_schema('user')
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq('Candice')
      end
    end
  end

  describe 'DELETE /api/v1/users/::id' do
    include_context 'with correct api version header'

    context 'when logged in as admin' do
      before { sign_in admin_user }

      it 'deletes any user' do
        delete("/api/v1/users/#{illinois_user.id}", params: {}, headers:)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when logged in as non admin' do
      before { sign_in illinois_user }

      it 'can delete the user\'s own account' do
        delete("/api/v1/users/#{illinois_user.id}", params: {}, headers:)
        expect(response).to have_http_status(:no_content)
      end

      it 'cannot delete other users\' accounts' do
        delete("/api/v1/users/#{nebraska_user.id}", params: {}, headers:)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/users' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in illinois_user }

      it 'returns only the user' do
        get('/api/v1/users', headers:)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'returns all users' do
        get('/api/v1/users', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('greeting_name')).to include(nebraska_user.greeting_name)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('users')
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    include_context 'with correct api version header'

    context 'when logged in as an Illinois non-admin user' do
      before { sign_in illinois_user }

      it 'returns the user using their ID' do
        get("/api/v1/users/#{illinois_user.id}", headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq(illinois_user.greeting_name)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('user')
      end

      it 'returns the user using /profile' do
        get('/api/v1/profile', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq(illinois_user.greeting_name)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('user')
      end

      it 'does not return another user' do
        get("/api/v1/users/#{nebraska_user.id}", headers:)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'does not return the illinois user' do
        get("/api/v1/users/#{illinois_user.id}", headers:)
        expect(response).to match_response_schema('user')
      end

      it 'returns the admin user using /profile' do
        get('/api/v1/profile', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq(admin_user.greeting_name)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('user')
      end

      it 'returns the nebraska user' do
        get("/api/v1/users/#{nebraska_user.id}", headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['greeting_name']).to eq(nebraska_user.greeting_name)
        expect(response).to match_response_schema('user')
      end

      # TODO: requires user policy changes
      # it 'returns the other user' do
      #   get "/api/v1/users/#{nebraska_user.id}", headers: headers
      #   parsed_response = response.parsed_body
      #   expect(parsed_response['greeting_name']).to eq(nebraska_user.greeting_name)
      #   expect(response).to match_response_schema('user')
      # end
    end
  end

  describe 'GET /api/v1/case_list_for_dashboard' do
    include_context 'with correct api version header'
    let!(:nebraska_user) { create(:confirmed_user, :nebraska) }
    let!(:illinois_user) { create(:confirmed_user) }
    let!(:illinois_business) { create(:business, user: illinois_user) }
    let!(:nebraska_business) { create(:business, :nebraska_ldds, user: nebraska_user) }
    let(:nebraska_business_two) { create(:business, :nebraska_ldds, user: nebraska_user) }

    before do
      create_list(
        :child,
        2,
        {
          business: nebraska_business,
          approvals: [
            create(:expired_approval, create_children: false),
            create(:approval, create_children: false)
          ]
        }
      )
      create_list(
        :child,
        2,
        {
          business: illinois_business,
          approvals: [
            create(:expired_approval, create_children: false),
            create(:approval, create_children: false)
          ]
        }
      )
    end

    context 'when logged in as a non-admin user in illinois' do
      before { sign_in illinois_user }

      it 'returns the correct data schema' do
        get('/api/v1/case_list_for_dashboard', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('illinois_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get('/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('illinois_case_list_for_dashboard')
      end

      it 'returns the correct cases when a business params is sent' do
        get('/api/v1/case_list_for_dashboard', params: { business: nebraska_business.id }, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end

    context 'when logged in as a non-admin user in nebraska' do
      before { sign_in nebraska_user }

      it 'returns the correct data schema' do
        get('/api/v1/case_list_for_dashboard', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get('/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end

      it 'returns the correct cases when a business params is sent' do
        get('/api/v1/case_list_for_dashboard', params: { business: nebraska_business_two.id }, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'returns the correct data schema' do
        get('/api/v1/case_list_for_dashboard', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get('/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end

      it 'returns the correct cases when a business params is sent' do
        get('/api/v1/case_list_for_dashboard', params: { business: nebraska_business_two.id }, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end
  end
end
