# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:url) { '/signup' }
  let(:params) do
    {
      user: {
        email: 'user@example.com',
        password: 'password'
      }
    }
  end

  context 'when user is unauthenticated' do
    path '/signup' do
      post 'creates a user' do
        tags 'users'
        consumes 'application/json', 'application/xml'
        parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
        parameter name: :user, in: :body, schema: {
          '$ref' => '#/definitions/createUser'
        }
  
        context 'on the right api version' do
          include_context 'correct api version header'
          # context 'when authenticated' do
          #   include_context 'authenticated user'
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
          response '400', 'bad request' do
            before(:each) { create(:user, email: params[:user][:email]) }
            let(:user) { { "user": params } }
            run_test! do
              expect(response['errors'].first['title']).to eq('Bad Request')
            end
          end
        end
  
        context 'on the wrong api version' do
          include_context 'incorrect api version header'
          response '500', 'internal server error' do
            let(:user) { { "user": params } }
            run_test!
          end
        end
      end
    end
  end
end
