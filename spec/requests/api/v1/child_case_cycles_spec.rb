# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'child_case_cycles API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:case_cycle_id) { create(:case_cycle, user: user).id }
  let!(:child_id) { create(:child, user: user).id }
  let!(:subsidy_rule_id) { create(:subsidy_rule).id }
  let!(:child_case_cycle_params) do
    {
      "part_days_allowed": 35,
      "full_days_allowed": 15,
      "case_cycle_id": case_cycle_id,
      "child_id": child_id,
      "subsidy_rule_id": subsidy_rule_id
    }
  end

  it_behaves_like 'it lists all items for a user', ChildCaseCycle

  describe 'create child case cycles' do
    let(:item_params) { child_case_cycle_params }

    path '/api/v1/child_case_cycles' do
      post 'creates a child_case_cycle' do
        tags 'child_case_cycles'

        produces 'application/json'
        consumes 'application/json'

        parameter name: :child_case_cycle, in: :body, schema: {
          '$ref' => '#/components/schemas/createChildCaseCycle'
        }

        context 'on the right api version' do
          include_context 'correct api version header'
          context 'when authenticated' do
            let(:child_case_cycle) { { 'child_case_cycle' => child_case_cycle_params } }

            context 'admin user' do
              include_context 'admin user'
              response '201', 'child_case_cycle created' do
                run_test! do
                  expect(response).to match_response_schema('child_case_cycle')
                end
              end
            end

            context 'child and case cycle owner' do
              before { sign_in user }
              response '201', 'child_case_cycle created' do
                run_test! do
                  expect(response).to match_response_schema('child_case_cycle')
                end
              end

              response '422', 'invalid request' do
                let(:child_case_cycle_params) { { 'child_case_cycle' => { 'key' => 'whatever' } } }
                run_test!
              end
            end

            context 'non-owner' do
              include_context 'authenticated user'
              response '403', 'Forbidden' do
                run_test!
              end
            end
          end

          include_context 'correct api version header'
          it_behaves_like '401 error if not authenticated with parameters', 'child_case_cycle'
        end

        it_behaves_like 'server error responses for wrong api version with parameters', 'child_case_cycle'
      end
    end
  end

  it_behaves_like 'admins and resource owners can retrieve an item', ChildCaseCycle do
    let(:item_params) { child_case_cycle_params }
    let(:item) { ChildCaseCycle.create! child_case_cycle_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can update an item', ChildCaseCycle, 'full_days_allowed', 100, 'strings are invalid' do
    let(:item_params) { child_case_cycle_params }
    let(:item) { ChildCaseCycle.create! child_case_cycle_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can delete an item', ChildCaseCycle do
    let(:item) { ChildCaseCycle.create! child_case_cycle_params }
    let(:owner) { user }
  end
end
