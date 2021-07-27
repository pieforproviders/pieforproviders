# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:params) do
    {
      user: {

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
    }
  end

  context 'when params are correct' do
    before do
      post '/signup', params: params
    end

    it 'signs up a new user; creates the user, returns 200' do
      expect(response).to have_http_status(201)
      expect(response).to match_response_schema('user')
      expect(JSON.parse(response.body)['state']).to eq('')
      expect(JSON.parse(response.body).keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
    end
  end

  context 'when signup params are incorrect' do
    let(:bad_params) { { user: { title: 'whatever ' } } }
    before { post '/signup', params: bad_params }

    it 'returns unprocessable entity' do
      expect(response.status).to eq 422
      expect(JSON.parse(response.body)['detail']['email'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['password'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['full_name'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['language'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['organization'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['timezone'].first).to eq("can't be blank")
    end
  end

  context 'when user already exists' do
    before do
      create(:confirmed_user, email: params[:user][:email])
      post '/signup', params: params
    end

    it 'returns unprocessable entity' do
      expect(response.status).to eq 422
      expect(JSON.parse(response.body)['detail']['email'].first).to eq('has already been taken')
    end
  end
end
