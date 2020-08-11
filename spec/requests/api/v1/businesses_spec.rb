# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'businesses API', type: :request do
  let(:user_id) { create(:confirmed_user).id }
  let!(:business_params) do
    {
      "name": 'Happy Hearts Child Care',
      "category": 'licensed_center_single',
      "user_id": user_id
    }
  end

  it_behaves_like 'it lists all items for a user', 'business'

  it_behaves_like 'it creates an item for a user', Business, 'business' do
    let(:item_params) { business_params }
  end

  it_behaves_like 'it retrieves an item with a slug, for a user', Business, 'business' do
    let(:item_params) { business_params }
  end

  it_behaves_like 'it updates an item with a slug, for a user', Business, 'business',
                  'name', 'Hogwarts School', nil do
    let(:item_params) { business_params }
  end

  it_behaves_like 'it deletes an item with a slug, for a user', Business, 'business' do
    let(:item_params) { business_params }
  end
end
