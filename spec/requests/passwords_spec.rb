# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  let!(:confirmed_user) { create(:confirmed_user) }

  describe 'POST /password' do
    context 'when passed the email' do
      let(:params) { { user: { email: confirmed_user.email } } }
      it 'resets the password' do
        post '/password', params: params
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['success']).to eq(true)
        expect(response.status).to eq(200)
      end
    end

    context 'without an email' do
      it 'does not reset the password' do
        post '/password'
        expect(response).to match_response_schema('password_error')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT /password' do
    let(:reset_token_params) { { user: { email: confirmed_user.email } } }
    before { post '/password', params: reset_token_params }
    context 'with a password token, new password and confirmation' do
      it 'changes the password' do
        reset_password_token = ActionMailer::Base.deliveries.last.html_part.body.match(/reset_password_token=(.+)">/x)[1]
        confirmed_user.reload
        put '/password', params: { user: { reset_password_token: reset_password_token, password: 'newPass1', password_confirmation: 'newPass1' } }
        expect(response.status).to eq(200)
      end
    end

    context 'without a password token' do
      let(:params) { { user: { password: 'newPass', password_confirmation: 'newPass' } } }
      it 'returns an error' do
        put '/password', params: params
        expect(response).to match_response_schema('password_error')
        expect(response.status).to eq(422)
      end
    end

    context 'with an incorrect password token' do
      let(:params) { { user: { reset_password_token: 'cactus', password: 'newPass', password_confirmation: 'newPass' } } }
      it 'returns an error' do
        put '/password', params: params
        expect(response).to match_response_schema('password_error')
        expect(response.status).to eq(422)
      end
    end
  end
end
