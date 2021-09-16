# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'sessions requests', type: :request do
  let(:user) { create(:confirmed_user) }
  let(:url) { '/login' }
  let(:params) do
    {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  context 'post /login' do
    context 'when params are correct' do
      before do
        post url, params: params
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['state']).to eq(user.state)
        expect(JSON.parse(response.body).keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
      end

      it 'returns JWT token in authorization header' do
        expect(response.headers['Authorization']).to be_present
      end
    end

    context 'when login params are incorrect' do
      before { post url }

      it 'returns unathorized status' do
        expect(response.status).to eq 401
      end
    end
  end

  context 'delete /logout' do
    let(:url) { '/logout' }

    it 'returns 204, no content' do
      delete url
      expect(response).to have_http_status(:no_content)
    end
  end
end
