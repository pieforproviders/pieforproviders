# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'businesses API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:zipcode) { create(:zipcode) }
  let!(:record_params) do
    {
      "name": 'Happy Hearts Child Care',
      "license_type": 'licensed_center',
      "user_id": user.id,
      "zipcode_id": zipcode.id,
      "county_id": zipcode.county.id
    }
  end
  let(:count) { 2 }
  let(:owner) { user }
  let(:owner_attributes) { { user: owner, zipcode: zipcode, county: zipcode.county } }
  let(:non_owner_attributes) { { zipcode: zipcode, county: zipcode.county } }
  let(:record) { Business.create! record_params }

  it_behaves_like 'it lists all records for a user', Business

  it_behaves_like 'it creates a record', Business

  it_behaves_like 'admins and resource owners can retrieve a record', Business

  it_behaves_like 'admins and resource owners can update a record', Business, 'name', 'Hogwarts School', nil

  it_behaves_like 'admins and resource owners can delete a record', Business
end
