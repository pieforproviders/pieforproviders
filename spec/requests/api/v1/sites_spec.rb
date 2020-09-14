# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'sites API', type: :request do
  # Use confirmed_user so that no confirmation email is sent
  let(:business_id) { create(:business, user: create(:confirmed_user)).id }
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

  it_behaves_like 'it creates an item', Site do
    let(:item_params) { site_params }
  end

  it_behaves_like 'it retrieves an item with a slug, for a user', Site do
    let(:item_params) { site_params }
  end

  it_behaves_like 'it updates an item with a slug', Site, 'name', 'Hogwarts School', nil do
    let(:item_params) { site_params }
  end

  it_behaves_like 'it deletes an item with a slug, for a user', Site do
    let(:item_params) { site_params }
  end
end
