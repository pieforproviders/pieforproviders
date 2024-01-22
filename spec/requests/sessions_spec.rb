# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'sessions requests' do
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

  describe 'POST /login' do
    context 'when params are correct' do
      before do
        post url, params:
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['state']).to eq(user.state)
        expect(response.parsed_body.keys).to contain_exactly('id',
                                                             'greeting_name',
                                                             'language',
                                                             'state',
                                                             'email',
                                                             'is_admin')
      end

      it 'returns JWT token in authorization header' do
        expect(response.headers['Authorization']).to be_present
      end
    end

    context 'when login params are incorrect' do
      before { post url }

      it 'returns unathorized status' do
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE /logout' do
    let(:url) { '/logout' }

    it 'returns 204, no content' do
      delete url
      expect(response).to have_http_status(:no_content)
    end
  end
end
