# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:params) do
    {
      email: 'user@example.com',
      full_name: 'Alicia Spinnet',
      greeting_name: 'Alicia',
      language: 'English',
      organization: 'Gryffindor Quidditch Team',
      password: 'password',
      password_confirmation: 'password',
      phone_number: '888-888-8888',
      phone_type: 'cell',
      timezone: 'Eastern Time (US & Canada)',
      service_agreement_accepted: true
    }
  end

  path '/signup' do
    post 'Signs up a new user; creates the user.' do
      tags 'users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        '$ref' => '#/components/schemas/createUser'
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
            expect(JSON.parse(response.body)['detail']['email'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['detail']['password'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['detail']['full_name'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['detail']['language'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['detail']['organization'].first).to eq("can't be blank")
            expect(JSON.parse(response.body)['detail']['timezone'].first).to eq("can't be blank")
          end
        end
        context 'with an existing user' do
          before(:each) { create(:confirmed_user, email: params[:email]) }
          let(:user) { { "user": params } }
          run_test! do
            expect(JSON.parse(response.body)['detail']['email'].first).to eq('has already been taken')
          end
        end
      end
    end
  end
end
