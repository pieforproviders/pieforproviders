# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'sites API', type: :request do
  let(:business_id) { create(:business, user: create(:confirmed_user)).id }
  let!(:site_params) do
    {
      "name": 'Evesburg Educational Center',
      "address": '1200 W Marberry Dr',
      "city": 'Gatlinburg',
      "state": 'TN',
      "zip": '12345',
      "county": 'Harrison',
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
