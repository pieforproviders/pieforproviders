# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Children', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:user_business) { create(:business_with_children, user: logged_in_user) }
  let!(:user_children) { user_business.children }
  let!(:non_user_business) { create(:business_with_children) }
  let!(:non_user_children) { non_user_business.children }
  let!(:admin_user) { create(:confirmed_user, admin: true) }

  describe 'GET /api/v1/children' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before { sign_in logged_in_user }

      it "returns the user's children" do
        get '/api/v1/children', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['full_name'] }).to include(user_children.first.full_name)
        expect(parsed_response.collect { |x| x['full_name'] }).not_to include(non_user_children.first.full_name)
        expect(response).to match_response_schema('children')
      end
    end

    context 'for admin user' do
      before { sign_in admin_user }

      it "returns all users' children" do
        get '/api/v1/children', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['full_name'] }).to include(user_children.first.full_name)
        expect(parsed_response.collect { |x| x['full_name'] }).to include(non_user_children.first.full_name)
        expect(response).to match_response_schema('children')
      end
    end
  end

  describe 'GET /api/v1/children/:id' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before { sign_in logged_in_user }

      it "returns the user's child" do
        get "/api/v1/children/#{user_children.first.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq(user_children.first.full_name)
        expect(response).to match_response_schema('child')
      end

      it 'does not return a child for another user' do
        get "/api/v1/children/#{non_user_children.first.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context 'for admin user' do
      before { sign_in admin_user }

      it "returns the user's child" do
        get "/api/v1/children/#{user_children.first.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq(user_children.first.full_name)
        expect(response).to match_response_schema('child')
      end

      it 'returns a child for another user' do
        get "/api/v1/children/#{non_user_children.first.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq(non_user_children.first.full_name)
        expect(response).to match_response_schema('child')
      end
    end
  end

  describe 'POST /api/v1/children' do
    include_context 'correct api version header'

    let(:params) do
      {
        child: {
          full_name: 'Parvati Patil',
          date_of_birth: '1981-04-09',
          business_id: user_business.id,
          approvals_attributes: [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
        }
      }
    end
    let(:params_without_business) { { child: params[:child].except(:business_id) } }

    context 'for non-admin user' do
      before { sign_in logged_in_user }

      it "creates a child for that user's business" do
        post '/api/v1/children', params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq('Parvati Patil')
        expect(logged_in_user.children.pluck(:full_name)).to include('Parvati Patil')
        expect(response).to match_response_schema('child')
      end

      context 'for nebraska' do
        let(:nebraska_business) { create(:business, :nebraska, user: create(:confirmed_user)) }

        before { sign_in nebraska_business.user }
        it "creates a child for that user's business" do
          params[:child][:business_id] = nebraska_business.id
          post '/api/v1/children', params: params, headers: headers
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['full_name']).to eq('Parvati Patil')
          expect(nebraska_business.children.pluck(:full_name)).to include('Parvati Patil')
          expect(response).to match_response_schema('child')
        end
      end

      context 'when including illinois approved amounts in params' do
        let(:params) do
          {
            child: {
              full_name: 'Parvati Patil',
              date_of_birth: '1981-04-09',
              business_id: user_business.id,
              approvals_attributes: [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
            },
            first_month_name: 'March',
            first_month_year: '2020'
          }
        end
        let(:one_month_amount) do
          params.merge(month1:
            {
              part_days_approved_per_week: 4,
              full_days_approved_per_week: 1
            })
        end
        let(:some_month_amounts) do
          6.times do |x|
            params["month#{x + 1}".to_sym] = {
              part_days_approved_per_week: 3,
              full_days_approved_per_week: 2
            }
          end
          params
        end
        let(:all_month_amounts) do
          12.times do |x|
            params["month#{x + 1}".to_sym] = {
              part_days_approved_per_week: 3,
              full_days_approved_per_week: 2
            }
          end
          params
        end

        it 'does not create approval amounts when no month is passed' do
          post '/api/v1/children', params: params, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts).to be_empty
          expect(response).to match_response_schema('child')
        end

        it 'creates 12 approval amounts when a single month is passed' do
          post '/api/v1/children', params: one_month_amount, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(12)
          expect(child.child_approvals.first.illinois_approval_amounts.pluck(:month)).to include(
            Date.parse("#{one_month_amount[:first_month_name]} #{one_month_amount[:first_month_year]}")
          )
          expect(response).to match_response_schema('child')
        end

        it 'creates 12 approval amounts when 12 months are passed' do
          post '/api/v1/children', params: all_month_amounts, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(12)
          expect(child.child_approvals.first.illinois_approval_amounts.pluck(:month)).to include(
            Date.parse("#{all_month_amounts[:first_month_name]} #{all_month_amounts[:first_month_year]}")
          )
          expect(response).to match_response_schema('child')
        end

        it 'creates exactly the number of approval amounts passed, if more than 1 and less than 12 months are present' do
          post '/api/v1/children', params: some_month_amounts, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(6)
          expect(child.child_approvals.first.illinois_approval_amounts.pluck(:month)).to include(
            Date.parse("#{some_month_amounts[:first_month_name]} #{some_month_amounts[:first_month_year]}")
          )
          expect(response).to match_response_schema('child')
        end
      end
    end

    context 'for admin user' do
      before { sign_in admin_user }

      it 'creates a child for the passed business' do
        post '/api/v1/children', params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq('Parvati Patil')
        expect(logged_in_user.children.pluck(:full_name)).to include('Parvati Patil')
        expect(response).to match_response_schema('child')
      end

      it 'fails unless the business is passed' do
        post '/api/v1/children', params: params_without_business, headers: headers
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT /api/v1/children/:id' do
    include_context 'correct api version header'

    let(:params) do
      {
        child: {
          full_name: 'Padma Patil'
        }
      }
    end

    context 'for non-admin user' do
      before { sign_in logged_in_user }

      it "updates the user's child" do
        put "/api/v1/children/#{user_children.first.id}", params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq('Padma Patil')
        expect(user_children.first.reload.full_name).to eq('Padma Patil')
        expect(response).to match_response_schema('child')
      end

      it 'does not update a child for another user' do
        put "/api/v1/children/#{non_user_children.first.id}", params: params, headers: headers
        expect(response.status).to eq(404)
      end

      it 'returns an error if the data is invalid' do
        params = {
          child: {
            date_of_birth: 'Not a date'
          }
        }
        put "/api/v1/children/#{user_children.first.id}", params: params, headers: headers
        expect(response.status).to eq(422)
      end
    end

    context 'for admin user' do
      before { sign_in admin_user }

      it "updates the user's child" do
        put "/api/v1/children/#{user_children.first.id}", params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq('Padma Patil')
        expect(user_children.first.reload.full_name).to eq('Padma Patil')
        expect(response).to match_response_schema('child')
      end

      it 'updates a child for another user' do
        put "/api/v1/children/#{non_user_children.first.id}", params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['full_name']).to eq('Padma Patil')
        expect(non_user_children.first.reload.full_name).to eq('Padma Patil')
        expect(response).to match_response_schema('child')
      end
    end
  end

  describe 'DELETE /api/v1/children/:id' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before { sign_in logged_in_user }

      it "soft-deletes the user's child" do
        delete "/api/v1/children/#{user_children.first.id}", headers: headers
        expect(response.status).to eq(204)
        expect(user_children.first.reload.deleted).to eq(true)
      end
    end

    context 'for admin user' do
      before { sign_in admin_user }

      it "soft-deletes the user's child" do
        delete "/api/v1/children/#{user_children.first.id}", headers: headers
        expect(response.status).to eq(204)
        expect(user_children.first.reload.deleted).to eq(true)
      end
    end
  end
end
