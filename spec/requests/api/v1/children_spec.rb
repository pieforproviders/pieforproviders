# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  # Use confirmed_user so that no confirmation email is sent
  let!(:confirmed_user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: confirmed_user) }
  let!(:child_params) do
    {
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "business_id": created_business.id
    }
  end

  it_behaves_like 'it lists all items for a user', Child

  it_behaves_like 'it creates an item', Child do
    let(:item_params) { child_params }
  end

  it_behaves_like 'admins and resource owners can retrieve an item', Child do
    let(:item_params) { child_params }
    let(:item) { Child.create! child_params }
    let(:owner) { confirmed_user }
  end

  it_behaves_like 'admins and resource owners can update an item', Child, 'full_name', 'Padma Patil', nil do
    let(:item_params) { child_params }
    let(:item) { Child.create! child_params }
    let(:owner) { confirmed_user }
  end

  it_behaves_like 'admins and resource owners can delete an item', Child do
    let(:item) { Child.create! child_params }
    let(:owner) { confirmed_user }
  end
end
