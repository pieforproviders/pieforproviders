# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users API', type: :request do
  # Do not send any emails (no confirmation emails, no password was changed emails)
  before(:each) do
    allow_any_instance_of(User).to receive(:send_confirmation_notification?).and_return(false)
    allow_any_instance_of(User).to receive(:send_password_change_notification?).and_return(false)
  end

  let!(:user_params) do
    {
      "email": 'fake_email@fake_email.com',
      "full_name": 'Oliver Twist',
      "greeting_name": 'Oliver',
      "language": 'English',
      "organization": 'Society for the Promotion of Elfish Welfare',
      "password": 'password1234!',
      "password_confirmation": 'password1234!',
      "phone_number": '912-444-5555',
      "phone_type": 'cell',
      "service_agreement_accepted": 'true',
      "timezone": 'Central Time (US & Canada)'
    }
  end

  describe 'list users' do
    path '/api/v1/users' do
      get 'retrieves all users' do
        tags 'users'

        produces 'application/json'

        context 'on the right api version' do
          include_context 'correct api version header'
          context 'admin users' do
            include_context 'admin user'
            response '200', 'users found' do
              run_test! do
                expect(response).to match_response_schema('users')
              end
            end
          end

          context 'non-admin users' do
            include_context 'authenticated user'
            response '403', 'forbidden' do
              run_test!
            end
          end

          it_behaves_like '401 error if not authenticated with parameters', 'user'
        end

        it_behaves_like 'server error responses for wrong api version with parameters', 'user'
      end
    end
  end

  describe 'user profile' do
    path '/api/v1/profile' do
      let(:record_params) { user_params }

      get 'retrieves the user profile' do
        tags 'users'

        produces 'application/json'

        context 'on the right api version' do
          include_context 'correct api version header'
          context 'when authenticated' do
            include_context 'authenticated user'
            response '200', 'profile found' do
              run_test! do
                expect(response).to match_response_schema('user')
              end
            end
          end

          it_behaves_like '401 error if not authenticated with parameters', 'user'
        end

        it_behaves_like 'server error responses for wrong api version with parameters', 'user'
      end
    end
  end
end
