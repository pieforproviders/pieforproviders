# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'GET /confirmation', type: :request do
  path '/confirmation' do
    get 'Confirms an unconfirmed user' do
      tags 'users'
      consumes 'application/json', 'application/xml'
      parameter name: :confirmation_token, in: :query, type: :string

      response '200', 'user confirmed' do
        let(:confirmation_token) { 'cactus' }
        run_test! do
          expect(response).to match_response_schema('user')
        end
      end

      # response '403', 'forbidden' do
      #   context 'with invalid token' do
      #     # let(:confirmation_token) { 'cactus' }
      #     run_test! do
      #       expect(JSON.parse(response.body)['errors'].first['detail']['timezone'].first).to eq("can't be blank")
      #     end
      #   end
      #   context 'with a confirmed user' do
      #     # let(:confirmation_token) { create(:confirmed_user).confirmation_token }
      #     run_test! do
      #       expect(JSON.parse(response.body)['errors'].first['detail']['email'].first).to eq('has already been taken')
      #     end
      #   end
      #   context 'with no token' do
      #     # let(:confirmation_token) { nil }
      #     run_test! do
      #       expect(JSON.parse(response.body)['errors'].first['detail']['email'].first).to eq('has already been taken')
      #     end
      #   end
      # end
    end
  end
end
