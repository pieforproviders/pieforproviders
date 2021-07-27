# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /confirmation', type: :request do
  let(:unconfirmed_user) { create(:unconfirmed_user) }
  let(:confirmed_user) { create(:confirmed_user) }
  let(:confirmation_token) { unconfirmed_user.confirmation_token }

  context 'with a valid token' do
    before do
      get '/confirmation', params: { confirmation_token: confirmation_token }
    end

    it 'confirms and returns the user' do
      expect(response).to match_response_schema('user')
      expect(JSON.parse(response.body)['state']).to eq(confirmed_user.state)
      expect(JSON.parse(response.body).keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
    end
  end

  context 'with an invalid, nil, or token for another user' do
    it 'returns an error' do
      get '/confirmation', params: { confirmation_token: 'cactus' }
      expect(response).to match_response_schema('confirmation_error')
      get '/confirmation', params: { confirmation_token: nil }
      expect(response).to match_response_schema('confirmation_error')
      get '/confirmation', params: { confirmation_token: confirmed_user.confirmation_token }
      expect(response).to match_response_schema('confirmation_error')
    end
  end
end
