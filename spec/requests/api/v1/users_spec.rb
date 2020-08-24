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

  it_behaves_like 'it lists all items for a user', User

  it_behaves_like 'it creates an item with the right api version and is authenticated', User do
    let(:item_params) { user_params }
  end

  describe 'creates a user' do
    path '/api/v1/users' do
      post 'creates a user' do
        tags 'users'
        consumes 'application/json', 'application/xml'
        parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
        parameter name: :user, in: :body, schema: {
          '$ref' => '#/components/schemas/createUser'
        }

        context 'on the right api version' do
          include_context 'correct api version header'

          context 'when not authenticated - CAN create a User' do
            response '201', 'user created' do
              let(:user) { { "user": user_params } }
              run_test! do
                expect(response).to match_response_schema('user')
              end
            end
            response '422', 'invalid request' do
              let(:user) { { "user": { "title": 'foo' } } }
              run_test!
            end
          end
        end
      end
    end
  end

  it_behaves_like 'it retrieves an item with a slug, for a user', User do
    let(:item_params) { user_params }
  end

  it_behaves_like 'it updates an item with a slug', User, 'full_name', 'Ron Weasley', nil do
    let(:item_params) { user_params }
  end

  it_behaves_like 'it deletes an item with a slug, for a user', User do
    let(:item_params) { user_params }
  end
end
