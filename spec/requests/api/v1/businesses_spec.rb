# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'businesses API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:admin) { create(:admin) }
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

  describe '#update' do
    let(:business_with_cases) { create(:business_with_children, user: owner, zipcode: zipcode, county: zipcode.county) }
    let(:id) { business_with_cases.id }
    path '/api/v1/businesses/{id}' do
      parameter name: :id, in: :path, type: :string

      put 'cannot update active on a business with active children' do
        tags 'businesses'

        produces 'application/json'
        consumes 'application/json'

        parameter name: :business, in: :body, schema: {
          '$ref' => '#/components/schemas/updateBusiness'
        }
        context 'on the right api version' do
          include_context 'correct api version header'
          context 'when authenticated' do
            context 'admin' do
              before { sign_in admin }

              response '422', 'Business cannot be updated' do
                let(:business) { { 'business' => { 'active' => 'false' } } }
                run_test!
              end
            end
          end
        end
      end
    end
  end
end
