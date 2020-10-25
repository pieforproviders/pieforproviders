# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:child_params) do
    {
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [attributes_for(:approval)]
    }
  end

  it_behaves_like 'it lists all items for a user', Child do
    let(:count) { 2 }
    let(:owner) { user }
    let(:owner_attributes) { { business: created_business } }
    let(:non_owner_attributes) { {} }
  end

  it_behaves_like 'it creates an item', Child do
    let(:item_params) { child_params }
  end

  it_behaves_like 'admins and resource owners can retrieve an item', Child do
    let(:item_params) { child_params }
    let(:item) { Child.create! child_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can update an item', Child, 'full_name', 'Padma Patil', nil do
    let(:item_params) { child_params }
    let(:item) { Child.create! child_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can delete an item', Child do
    let(:item) { Child.create! child_params }
    let(:owner) { user }
  end
end
