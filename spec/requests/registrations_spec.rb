# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:params) do
    {
      user: {

        email: 'user@example.com',
        full_name: 'Alicia Spinnet',
        get_from_pie: 'Some stuff',
        greeting_name: 'Alicia',
        language: 'English',
        organization: 'Gryffindor Quidditch Team',
        password: 'password',
        password_confirmation: 'password',
        phone_number: '888-888-8888',
        phone_type: 'cell',
        timezone: 'Eastern Time (US & Canada)',
        service_agreement_accepted: true,
        state: 'NE'
      }
    }
  end

  context 'when params are correct' do
    before do
      post '/signup', params: params
    end

    it 'signs up a new user; creates the user, returns 201' do
      expect(response).to have_http_status(:created)
      expect(response).to match_response_schema('user')
      expect(JSON.parse(response.body)['state']).to eq('NE')
      expect(JSON.parse(response.body).keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
    end
  end

  context 'with correct survey params' do
    let(:survey_params) do
      params[:user].store(:stressed_about_billing, 'True')
      params[:user].store(:too_much_time, 'Mostly True')
      params[:user].store(:accept_more_subsidy_families, 'False')
      params[:user].store(:not_as_much_money, 'Mostly False')
      params[:user].store(:get_from_pie, 'Some stuff and more stuff.')
      params
    end

    before do
      post '/signup', params: survey_params
    end

    it 'signs up a new user; creates the user, returns 201' do
      expect(response).to have_http_status(:created)
      expect(response).to match_response_schema('user')
      expect(JSON.parse(response.body)['state']).to eq('NE')
      expect(JSON.parse(response.body).keys).to contain_exactly('id', 'greeting_name', 'language', 'state')
    end
  end

  context 'with incorrect survey params' do
    before do
      post '/signup', params: bad_survey_params
    end

    describe 'with invalid survey params' do
      let(:bad_survey_params) do
        params[:user].store(:stressed_about_billing, 'Bonk')
        params
      end

      it 'returns unprocessable entity' do
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['detail']['stressed_about_billing'].first).to eq('is not included in the list')
      end
    end

    describe 'with missing required survey params' do
      let(:bad_survey_params) do
        params[:user].delete(:get_from_pie)
        params
      end

      it 'returns unprocessable entity' do
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['detail']['get_from_pie'].first).to eq("can't be blank")
      end
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
