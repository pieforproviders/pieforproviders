# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Confirmations', type: :request do
  let!(:unconfirmed_user) { create(:unconfirmed_user) }

  describe 'POST /confirmation' do
    context 'with an email' do
      let(:params) { { user: { email: unconfirmed_user.email } } }
      it 'creates the confirmation' do
        post '/confirmation', params: params
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['success']).to eq(true)
        expect(response.status).to eq(200)
      end
    end

    context 'without an email' do
      it 'does not create the confirmation' do
        post '/confirmation'
        expect(response).to match_response_schema('confirmation_error')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'GET /confirmation' do
    context 'with a valid confirmationtoken' do
      it 'changes the password' do
        get "/confirmation?confirmation_token=#{unconfirmed_user.confirmation_token}"
        expect(response.status).to eq(200)
      end
    end

    context 'without a confirmation token' do
      it 'returns an error' do
        get '/confirmation'
        expect(response).to match_response_schema('confirmation_error')
        expect(response.status).to eq(403)
      end
    end

    context 'with an incorrect confirmation token' do
      it 'returns an error' do
        get '/confirmation?confirmation_token=cactus'
        expect(response).to match_response_schema('confirmation_error')
        expect(response.status).to eq(403)
      end
    end
  end
end
