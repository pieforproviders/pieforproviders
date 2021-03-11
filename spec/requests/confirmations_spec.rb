# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'GET /confirmation', type: :request do
  let(:unconfirmed_user) { create(:unconfirmed_user) }
  let(:confirmed_user) { create(:confirmed_user) }
  path '/confirmation' do
    get "Confirms the user's account." do
      consumes 'application/json'
      parameter name: 'confirmation_token', in: :query, type: :string

      response '200', 'user confirmed' do
        let(:confirmation_token) { unconfirmed_user.confirmation_token }
        run_test! do
          expect(response).to match_response_schema('user')
          expect(JSON.parse(response.body)['state']).to eq(confirmed_user.state)
          expect(JSON.parse(response.body).keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
        end
      end

      response '403', 'forbidden' do
        context 'invalid token' do
          let(:confirmation_token) { 'cactus' }
          run_test! do
            expect(response).to match_response_schema('confirmation_error')
          end
        end

        context 'no token' do
          let(:confirmation_token) { nil }
          run_test! do
            expect(response).to match_response_schema('confirmation_error')
          end
        end

        context 'confirmed user' do
          let(:confirmation_token) { confirmed_user.confirmation_token }
          run_test! do
            expect(response).to match_response_schema('confirmation_error')
          end
        end
      end
    end
  end
end
