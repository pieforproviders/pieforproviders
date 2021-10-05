# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Businesses', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:user_business) { create(:business_with_children, user: logged_in_user) }
  let!(:non_user_business) { create(:business_with_children) }
  let!(:admin_user) { create(:confirmed_user, admin: true) }

  describe 'GET /api/v1/businesses' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "returns the user's businesses" do
        get '/api/v1/businesses', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['name'] }).to include(user_business.name)
        expect(parsed_response.collect { |x| x['name'] }).not_to include(non_user_business.name)
        expect(response).to match_response_schema('businesses')
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "returns all users' businesses" do
        get '/api/v1/businesses', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['name'] }).to include(user_business.name)
        expect(parsed_response.collect { |x| x['name'] }).to include(non_user_business.name)
        expect(response).to match_response_schema('businesses')
      end
    end
  end

  describe 'GET /api/v1/businesses/:id' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "returns the user's business" do
        get "/api/v1/businesses/#{user_business.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq(user_business.name)
        expect(response).to match_response_schema('business')
      end

      it 'does not return a business for another user' do
        get "/api/v1/businesses/#{non_user_business.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "returns the user's business" do
        get "/api/v1/businesses/#{user_business.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq(user_business.name)
        expect(response).to match_response_schema('business')
      end

      it 'returns a business for another user' do
        get "/api/v1/businesses/#{non_user_business.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq(non_user_business.name)
        expect(response).to match_response_schema('business')
      end
    end
  end

  describe 'POST /api/v1/businesses' do
    include_context 'with correct api version header'

    let(:params_without_user) do
      {
        business: {
          name: 'Happy Hearts Child Care',
          license_type: 'licensed_center',
          zipcode: '60606',
          county: 'Cook'
        }
      }
    end
    let(:params_with_user) { { business: params_without_user[:business].merge({ user_id: logged_in_user.id }) } }

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it 'creates a business for that user' do
        post '/api/v1/businesses', params: params_without_user, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Happy Hearts Child Care')
        expect(logged_in_user.businesses.pluck(:name)).to include('Happy Hearts Child Care')
        expect(response).to match_response_schema('business')
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'creates a business for the passed user' do
        post '/api/v1/businesses', params: params_with_user, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Happy Hearts Child Care')
        expect(logged_in_user.businesses.pluck(:name)).to include('Happy Hearts Child Care')
        expect(response).to match_response_schema('business')
      end

      it 'fails unless the user is passed' do
        post '/api/v1/businesses', params: params_without_user, headers: headers
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT /api/v1/businesses/:id' do
    include_context 'with correct api version header'

    let(:params) do
      {
        business: {
          name: 'Hogwarts School of Witchcraft and Wizardry'
        }
      }
    end

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "updates the user's business" do
        put "/api/v1/businesses/#{user_business.id}", params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Hogwarts School of Witchcraft and Wizardry')
        expect(user_business.reload.name).to eq('Hogwarts School of Witchcraft and Wizardry')
        expect(response).to match_response_schema('business')
      end

      it 'does not update a business for another user' do
        put "/api/v1/businesses/#{non_user_business.id}", params: params, headers: headers
        expect(response.status).to eq(404)
      end

      it 'cannot update a business to inactive' do
        put "/api/v1/businesses/#{user_business.id}",
            params: {
              business: params.merge({ active: false })
            },
            headers: headers
        expect(response.status).to eq(200)
        expect(user_business.reload.active).to eq(true)
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "updates the user's business" do
        put "/api/v1/businesses/#{user_business.id}", params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Hogwarts School of Witchcraft and Wizardry')
        expect(user_business.reload.name).to eq('Hogwarts School of Witchcraft and Wizardry')
        expect(response).to match_response_schema('business')
      end

      it 'updates a business for another user' do
        put "/api/v1/businesses/#{non_user_business.id}", params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Hogwarts School of Witchcraft and Wizardry')
        expect(non_user_business.reload.name).to eq('Hogwarts School of Witchcraft and Wizardry')
        expect(response).to match_response_schema('business')
      end

      it 'cannot update a business to inactive if it has active children' do
        put "/api/v1/businesses/#{user_business.id}",
            params: {
              business: params.merge({ active: false })
            },
            headers: headers
        expect(response.status).to eq(422)
        expect(user_business.reload.active).to eq(true)
      end

      it 'can update a business to inactive if it has no children' do
        user_business.children.destroy_all
        put "/api/v1/businesses/#{user_business.id}",
            params: {
              business: params.merge({ active: false })
            },
            headers: headers
        expect(response.status).to eq(200)
        expect(user_business.reload.active).to eq(false)
      end

      it 'can update a business to inactive if it has no active children' do
        user_business.children.each { |child| child.update!(active: false) }
        put "/api/v1/businesses/#{user_business.id}",
            params: {
              business: params.merge({ active: false })
            },
            headers: headers
        expect(response.status).to eq(200)
        expect(user_business.reload.active).to eq(false)
      end
    end
  end

  describe 'DELETE /api/v1/businesses/:id' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "soft-deletes the user's business if there are no active children" do
        user_business.children.destroy_all
        delete "/api/v1/businesses/#{user_business.id}", headers: headers
        expect(response.status).to eq(204)
        expect(user_business.reload.active).to eq(true)
        expect(user_business.reload.deleted_at).to eq(Time.current.to_date)
        expect(response.body).to be_empty
      end

      it "does not soft-delete the user's business if there are active children" do
        delete "/api/v1/businesses/#{user_business.id}", headers: headers
        expect(response.status).to eq(422)
        expect(user_business.reload.active).to eq(true)
        expect(user_business.reload.deleted_at).to be_nil
        expect(JSON.parse(response.body).keys).to include('children')
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "soft-deletes the user's business if there are no active children" do
        user_business.children.destroy_all
        delete "/api/v1/businesses/#{user_business.id}", headers: headers
        expect(response.status).to eq(204)
        expect(user_business.reload.active).to eq(true)
        expect(user_business.reload.deleted_at).to eq(Time.current.to_date)
      end

      it "does not soft-delete the user's business if there are active children" do
        delete "/api/v1/businesses/#{user_business.id}", headers: headers
        expect(response.status).to eq(422)
        expect(user_business.reload.active).to eq(true)
        expect(user_business.reload.deleted_at).to be_nil
      end
    end
  end
end
