# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  let!(:unconfirmed_user) { create(:unconfirmed_user) }

  describe 'POST /signup' do
    context 'with valid params' do
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
      it 'creates the user' do
        post '/signup', params: params
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['state']).to eq('')
        expect(parsed_response.keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
        expect(response.status).to eq(201)
        expect(response).to match_response_schema('user')
      end
    end

    context 'with invalid params' do
      it 'does not create the user' do
        post '/signup', params: { user: { phone: '1112228888' } }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['detail']['email'].first).to eq("can't be blank")
        expect(parsed_response['detail']['password'].first).to eq("can't be blank")
        expect(parsed_response['detail']['full_name'].first).to eq("can't be blank")
        expect(parsed_response['detail']['language'].first).to eq("can't be blank")
        expect(parsed_response['detail']['organization'].first).to eq("can't be blank")
        expect(parsed_response['detail']['timezone'].first).to eq("can't be blank")
        expect(response.status).to eq(422)
      end
    end

    context 'with an existing user' do
      it 'does not create the user' do
        post '/signup', params: { user: { email: create(:user).email } }
        expect(JSON.parse(response.body)['detail']['email'].first).to eq('has already been taken')
        expect(response.status).to eq(422)
      end
    end
  end
end
