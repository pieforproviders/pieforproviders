# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'sites API', type: :request do
  # Use confirmed_user so that no confirmation email is sent
  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:business_id) { create(:business, user: user).id }
  let(:tn) { CreateOrSampleLookup.random_state_or_create }
  let(:tn_county) { CreateOrSampleLookup.random_county_or_create(state: tn) }
  let(:tn_city) { CreateOrSampleLookup.random_city_or_create(state: tn, county: tn_county) }
  let(:tn_city_zip) { CreateOrSampleLookup.random_zipcode_or_create(state: tn, city: tn_city) }

  let!(:site_params) do
    {
      "name": 'Evesburg Educational Center',
      "address": '1200 W Marberry Dr',
      "city_id": tn_city.id,
      "state_id": tn.id,
      "zip_id": tn_city_zip.id,
      "county_id": tn_county.id,
      "qris_rating": '4',
      "business_id": business_id
    }
  end

  it_behaves_like 'it lists all items for a user', Site

  describe 'create sites' do
    path '/api/v1/sites' do
      post 'creates a site' do
        tags 'sites'

        produces 'application/json'
        consumes 'application/json'

        parameter name: :site, in: :body, schema: {
          '$ref' => '#/components/schemas/createSite'
        }

        context 'on the right api version' do
          include_context 'correct api version header'
          it_behaves_like '401 error if not authenticated with parameters', 'site' do
            let(:item_params) { site_params }
          end

          context 'when authenticated' do
            context 'admin user' do
              include_context 'admin user'
              response '201', 'site created' do
                let(:site) { { 'site' => site_params } }
                run_test! do
                  expect(response).to match_response_schema('site')
                end
              end
            end

            context 'business owner' do
              before { sign_in user }
              response '201', 'site created' do
                let(:site) { { 'site' => site_params } }
                run_test! do
                  expect(response).to match_response_schema('site')
                end
              end

              response '422', 'invalid request' do
                let(:site) { { 'site' => { 'blorf': 'whatever' } } }
                run_test!
              end
            end

            context 'non-owner' do
              before { sign_in non_owner }
              response '403', 'Forbidden' do
                let(:site) { { 'site' => site_params } }
                run_test!
              end
            end
          end
        end
      end
    end
  end

  it_behaves_like 'admins and resource owners can retrieve an item with a slug', Site do
    let(:item_params) { site_params }
    let(:item) { Site.create! site_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can update an item with a slug', Site, 'name', 'Hogwarts School', nil do
    let(:item_params) { site_params }
    let(:item) { Site.create! site_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can delete an item with a slug', Site do
    let(:item) { Site.create! site_params }
    let(:owner) { user }
  end
end
