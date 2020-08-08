# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let(:user_id) { create(:user).id }
  let(:site_id) { create(:site).id }
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

  path '/api/v1/children' do
    get 'lists all children' do
      tags 'children'
      produces 'application/json'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'children found' do
            run_test! do
              expect(response).to match_response_schema('children')
            end
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            run_test!
          end
        end
      end
    end

    post 'creates a child' do
      tags 'children'
      consumes 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      parameter name: :child, in: :body, schema: {
        '$ref' => '#/definitions/createChild'
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '201', 'child created' do
            context 'with child_site params including dates' do
              let(:child) { { "child": child_params } }
              run_test! do
                expect(response).to match_response_schema('child')
                expect(Child.last.child_sites.length).not_to be(0)
              end
            end
            context 'with child_site params with no dates' do
              let(:child) { { "child": child_params_no_site_dates } }
              run_test! do
                expect(response).to match_response_schema('child')
                expect(Child.last.child_sites.length).not_to be(0)
              end
            end
            context 'without child_site params' do
              let(:child) { { "child": child_params_no_site } }
              run_test! do
                expect(response).to match_response_schema('child')
                expect(Child.last.child_sites.length).to be(0)
              end
            end
          end
          response '422', 'invalid request' do
            let(:child) { { "child": { "title": 'whatever' } } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:child) { { "child": child_params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:child) { { "child": child_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:child) { { "child": child_params } }
            run_test!
          end
        end
      end
    end
  end

  path '/api/v1/children/{slug}' do
    parameter name: :slug, in: :path, type: :string
    let(:slug) { Child.create!(child_params).slug }

    get 'retrieves a child' do
      tags 'children'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'child found' do
            run_test! do
              expect(response).to match_response_schema('child')
            end
          end

          response '404', 'child not found' do
            let(:slug) { 'invalid' }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            run_test!
          end
        end
      end
    end

    put 'updates a child' do
      tags 'children'
      consumes 'application/json', 'application/xml'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :child, in: :body, schema: {
        '$ref' => '#/definitions/updateChild'
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'child updated' do
            let(:child) { { "child": child_params.merge("full_name": 'Padma Patil') } }
            run_test! do
              expect(response).to match_response_schema('child')
              expect(response.parsed_body['full_name']).to eq('Padma Patil')
            end
          end

          response '422', 'child cannot be updated' do
            let(:child) { { "child": { "full_name": nil } } }
            run_test!
          end

          response '404', 'child not found' do
            let(:slug) { 'invalid' }
            let(:child) { { "child": child_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:child) { { "child": child_params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:child) { { "child": child_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:child) { { "child": child_params } }
            run_test!
          end
        end
      end
    end

    delete 'deletes a child' do
      tags 'children'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '204', 'child deleted' do
            run_test!
          end

          response '404', 'child not found' do
            let(:slug) { 'invalid' }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            run_test!
          end
        end
      end
    end
  end
end
