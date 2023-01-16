# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /signup' do
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
        state: 'NE',
        too_much_time: 'True',
        accept_more_subsidy_families: 'False',
        not_as_much_money: 'Mostly True',
        stressed_about_billing: 'Mostly False'
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

  context 'with get_from_pie optional param' do
    let(:survey_params) do
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

  context 'with invalid required survey params' do
    before do
      post '/signup', params: bad_survey_params
    end

    # describe 'with invalid survey params' do
    #   let(:bad_survey_params) do
    #     params[:user].store(:stressed_about_billing, 'Bonk')
    #     params
    #   end

    #   it 'returns unprocessable entity' do
    #     expect(response).to have_http_status :unprocessable_entity
    #     expect(JSON.parse(response.body)['detail']['stressed_about_billing'].first).to
    #                                                   eq('is not included in the list')
    #   end
    # end

    describe 'with missing required survey params' do
      let(:bad_survey_params) do
        params[:user].delete(:too_much_time)
        params
      end

      it 'returns unprocessable entity' do
        expect(response).to have_http_status :unprocessable_entity
        expect(JSON.parse(response.body)['detail']['too_much_time'].first).to eq('is not included in the list')
      end
    end
  end

  context 'when signup params are incorrect' do
    let(:bad_params) { { user: { title: 'whatever ' } } }

    before { post '/signup', params: bad_params }

    it 'returns unprocessable entity' do
      expect(response).to have_http_status :unprocessable_entity
      expect(JSON.parse(response.body)['detail']['email'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['password'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['full_name'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['language'].first).to eq("can't be blank")
      expect(JSON.parse(response.body)['detail']['timezone'].first).to eq("can't be blank")
    end
  end

  context 'when user already exists' do
    before do
      create(:confirmed_user, email: params[:user][:email])
      post '/signup', params: params
    end

    it 'returns unprocessable entity' do
      expect(response).to have_http_status :unprocessable_entity
      expect(JSON.parse(response.body)['detail']['email'].first).to eq('has already been taken')
    end
  end
end
