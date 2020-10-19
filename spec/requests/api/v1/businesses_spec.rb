# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'businesses API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:zipcode) { create(:zipcode) }
  let!(:business_params) do
    {
      "name": 'Happy Hearts Child Care',
      "license_type": 'licensed_center',
      "user_id": user.id,
      "zipcode_id": zipcode.id,
      "county_id": zipcode.county.id
    }
  end

  it_behaves_like 'it lists all items for a user', Business

  it_behaves_like 'it creates an item', Business do
    let(:item_params) { business_params }
  end

  it_behaves_like 'admins and resource owners can retrieve an item', Business do
    let(:item_params) { business_params }
    let(:item) { Business.create! business_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can update an item', Business, 'name', 'Hogwarts School', nil do
    let(:item_params) { business_params }
    let(:item) { Business.create! business_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can delete an item', Business do
    let(:item) { Business.create! business_params }
    let(:owner) { user }
  end
end
