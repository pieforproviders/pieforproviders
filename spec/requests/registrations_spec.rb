# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:url) { '/signup' }
  let(:params) do
    {
      email: 'user@example.com',
      full_name: 'Alicia Spinnet',
      greeting_name: 'Alicia',
      language: 'English',
      phone_type: '888-888-8888',
      organization: 'Gryffindor Quidditch Team',
      password: 'password',
      password_confirmation: 'password',
      phone_number: '888-888-8888',
      timezone: 'Eastern Time (US & Canada)'
    }
  end

  path '/signup' do
    post 'creates a user' do
      tags 'users'
      consumes 'application/json', 'application/xml'
      parameter name: :user, in: :body, schema: {
        '$ref' => '#/definitions/createUser'
      }

      response '201', 'user created' do
        let(:user) { { "user": params } }
        run_test! do
          expect(response).to match_response_schema('user')
        end
      end

      response '422', 'invalid request' do
        context 'with bad data' do
          let(:user) { { "user": { "title": 'whatever' } } }
          run_test! do
            expect(JSON.parse(response.body)['errors'].first['detail']['email'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['errors'].first['detail']['password'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['errors'].first['detail']['full_name'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['errors'].first['detail']['language'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['errors'].first['detail']['organization'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['errors'].first['detail']['timezone'].first).to eq("can't be blank")
          end
        end
        context 'with an existing user' do
          before(:each) { create(:confirmed_user, email: params[:email]) }
          let(:user) { { "user": params } }
          run_test! do
            expect(JSON.parse(response.body)['errors'].first['detail']['email'].first).to eq('has already been taken')
          end
        end
      end
    end
  end
end
