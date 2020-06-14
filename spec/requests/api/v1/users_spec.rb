# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users API', type: :request do
  let!(:params) do
    {
      "email": 'fake_email@fake_email.com',
      "full_name": 'Oliver Twist',
      "greeting_name": 'Oliver',
      "language": 'English',
      "phone_type": '912-444-5555',
      "organization": 'Society for the Promotion of Elfish Welfare',
      "password": 'password1234!',
      "password_confirmation": 'password1234!',
      "phone_number": '912-444-5555',
      "service_agreement_accepted": 'true',
      "timezone": 'Central Time (US & Canada)'
    }
  end

  path '/api/v1/users' do
    get 'lists all users' do
      tags 'users'
      produces 'application/json'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'users found' do
            run_test! do
              expect(response).to match_response_schema('users')
            end
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            run_test!
          end
        end
      end
    end

    post 'creates a user' do
      tags 'users'
      consumes 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      parameter name: :user, in: :body, schema: {
        '$ref' => '#/definitions/createUser'
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '201', 'user created' do
            let(:user) { { "user": params } }
            run_test! do
              expect(response).to match_response_schema('user')
            end
          end
          response '422', 'invalid request' do
            let(:user) { { "user": { "title": 'whatever' } } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '201', 'user created' do
            let(:user) { { "user": params } }
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

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:user) { { "user": params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:user) { { "user": params } }
            run_test!
          end
        end
      end
    end
  end

  path '/api/v1/users/{slug}' do
    parameter name: :slug, in: :path, type: :string
    let(:slug) { User.create!(params).slug }

    get 'retrieves a user' do
      tags 'users'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'user found' do
            run_test! do
              expect(response).to match_response_schema('user')
            end
          end

          response '404', 'user not found' do
            let(:slug) { 'invalid' }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            run_test!
          end
        end
      end
    end

    put 'updates a user' do
      tags 'users'
      consumes 'application/json', 'application/xml'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :user, in: :body, schema: {
        '$ref' => '#/definitions/updateUser'
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'user updated' do
            let(:user) { { "user": params.merge("full_name": 'Ron Weasley') } }
            run_test! do
              expect(response).to match_response_schema('user')
              expect(response.parsed_body['full_name']).to eq('Ron Weasley')
            end
          end

          response '422', 'user cannot be updated' do
            let(:user) { { "user": { "email": nil } } }
            run_test!
          end

          response '404', 'user not found' do
            let(:slug) { 'invalid' }
            let(:user) { { "user": params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:user) { { "user": params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:user) { { "user": params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:user) { { "user": params } }
            run_test!
          end
        end
      end
    end

    delete 'deletes a user' do
      tags 'users'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '204', 'user deleted' do
            run_test!
          end

          response '404', 'user not found' do
            let(:slug) { 'invalid' }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            run_test!
          end
        end
      end
    end
  end
end
