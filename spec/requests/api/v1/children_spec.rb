# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:non_owner_business) { create(:business, zipcode: created_business.zipcode, county: created_business.county) }
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

  describe '#case_list_for_dashboard' do
    path '/api/v1/case_list_for_dashboard' do
      get 'lists all cases with associated data for a user' do
        tags 'children', 'dashboard'

        # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
        produces 'application/json'

        # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
        # security [{ token: [] }]

        include_context 'correct api version header'
        let!(:expired_approval) { create(:expired_approval, case_number: '1234567A', create_children: false) }
        let!(:expired_approvals) { create_list(:expired_approval, count, create_children: false) }
        let!(:current_approval) { create(:approval, case_number: '1234567B', create_children: false) }
        let!(:current_approvals) { create_list(:approval, count, create_children: false) }
        let!(:owner_records) { create_list(:child, count, owner_attributes.merge(approvals: [expired_approval, current_approval])) }
        let!(:owner_inactive_records) { create_list(:child, count, owner_attributes.merge(active: false, approvals: [expired_approvals.sample, current_approvals.sample])) }
        let!(:non_owner_records) { create_list(:child, count, non_owner_attributes.merge(approvals: [expired_approvals.sample, current_approvals.sample])) }
        let!(:non_owner_inactive_records) { create_list(:child, count, non_owner_attributes.merge(active: false, approvals: [expired_approvals.sample, current_approvals.sample])) }

        context 'admin user' do
          include_context 'admin user'
          response '200', 'active cases found' do
            run_test! do
              expect(JSON.parse(response.body).size).to eq(count * 2)
              expect(JSON.parse(response.body).first['approvals'].size).to eq(1)
              expect(JSON.parse(response.body).first['approvals'].first['case_number']).to eq('1234567B')
              expect(response).to match_response_schema('case_list_for_dashboard')
            end
          end
        end

        context 'resource owner' do
          before { sign_in owner }

          response '200', 'active cases found' do
            run_test! do
              expect(JSON.parse(response.body).size).to eq(count)
              expect(response).to match_response_schema('case_list_for_dashboard')
            end
          end
        end

        context 'non-owner' do
          include_context 'authenticated user'
          response '200', 'active cases found' do
            run_test! do
              expect(JSON.parse(response.body).size).to eq(0)
            end
          end
        end
      end
    end
  end
end
