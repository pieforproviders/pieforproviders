# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  # Use confirmed_user so that no confirmation email is sent
  let(:confirmed_user) { create(:confirmed_user) }
  let(:user_id) { confirmed_user.id }
  let(:created_business) { create(:business, user: confirmed_user) }
  let(:site_id) { create(:site, business: created_business).id }
  let!(:child_params) do
    {
      "ccms_id": '1234567890',
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "user_id": user_id,
      "child_sites_attributes": [{
        "site_id": site_id,
        "started_care": Time.zone.today - 3.years,
        "ended_care": Time.zone.today - 1.year
      }]
    }
  end
  let!(:child_params_no_site_dates) do
    {
      "ccms_id": '1234567890',
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "user_id": user_id,
      "child_sites_attributes": [{
        "site_id": site_id
      }]
    }
  end
  let!(:child_params_no_site) do
    {
      "ccms_id": '1234567890',
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "user_id": user_id
    }
  end

  it_behaves_like 'it lists all items for a user', Child

  it_behaves_like 'it creates an item', Child do
    let(:item_params) { child_params }
  end

  context 'with child_site params with no dates' do
    it_behaves_like 'it creates an item', Child do
      let(:item_params) { child_params_no_site_dates }
    end
  end

  context 'without child_site params' do
    it_behaves_like 'it creates an item', Child do
      let(:item_params) { child_params_no_site }
    end
  end

  it_behaves_like 'admins and resource owners can retrieve an item with a slug', Child do
    let(:item_params) { child_params }
    let(:item) { Child.create! child_params }
    let(:owner) { confirmed_user }
  end

  it_behaves_like 'admins and resource owners can update an item with a slug', Child, 'full_name', 'Padma Patil', nil do
    let(:item_params) { child_params }
    let(:item) { Child.create! child_params }
    let(:owner) { confirmed_user }
  end

  it_behaves_like 'admins and resource owners can delete an item with a slug', Child do
    let(:item) { Child.create! child_params }
    let(:owner) { confirmed_user }
  end
end
