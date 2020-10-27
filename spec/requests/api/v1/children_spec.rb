# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:non_owner_business) { create(:business, zipcode: created_business.zipcode, county: created_business.zipcode.county) }
  let!(:record_params) do
    {
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [attributes_for(:approval)]
    }
  end
  let(:count) { 2 }
  let(:owner) { user }
  let(:owner_attributes) { { business: created_business } }
  let(:non_owner_attributes) { { business: non_owner_business } }
  let(:record) { Child.create! record_params }

  it_behaves_like 'it lists all records for a user', Child

  it_behaves_like 'it creates a record', Child

  it_behaves_like 'admins and resource owners can retrieve a record', Child

  it_behaves_like 'admins and resource owners can update a record', Child, 'full_name', 'Padma Patil', nil

  it_behaves_like 'admins and resource owners can delete a record', Child
end
