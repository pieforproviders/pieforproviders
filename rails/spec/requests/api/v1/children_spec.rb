# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let!(:user) { create(:user) }

  let!(:params) do
    {
      "full_name": 'Ron Weasley',
      "greeting_name": 'Roonil Wazlib',
      "date_of_birth": '2016-06-24',
      "user_ids": [user.id]
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
        # context 'when authenticated' do
        # include_context 'authenticated user'
        response '200', 'children found' do
          run_test! do
            expect(response).to match_response_schema('children')
          end
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '401', 'not authorized' do
        #     run_test!
        #   end
        # end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        # context 'when authenticated' do
        # include_context 'authenticated user'
        response '500', 'internal server error' do
          run_test!
        end
        # end

        # context 'when not authenticated' do
        # include_context 'unauthenticated user'
        # response '500', 'internal server error' do
        #   run_test!
        # end
        # end
      end
    end

    post 'creates a child' do
      tags 'children'
      consumes 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :child, in: :body, schema: {
        '$ref' => '#/definitions/createChild'
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '201', 'child created' do
          let(:child) { { "child": params } }
          run_test! do
            expect(response).to match_response_schema('child')
          end
        end

        response '422', 'invalid request' do
          let(:child) { { "child": { "title": 'foo' } } }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '401', 'not authorized' do
        #     let(:child) { { "child": params } }
        #     run_test!
        #   end
        # end
      end
      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '500', 'internal server error' do
          let(:child) { { "child": params } }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '500', 'internal server error' do
        #     let(:child) { { "child": params } }
        #     run_test!
        #   end
        # end
      end
    end
  end

  path '/api/v1/children/{id}' do
    parameter name: :id, in: :path, type: :string
    let(:id) { Child.create(params).id }
    get 'retrieves a child' do
      tags 'children'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '200', 'child found' do
          run_test! do
            expect(response).to match_response_schema('child')
          end
        end

        response '404', 'child not found' do
          let(:id) { 'invalid' }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '401', 'not authorized' do
        #     run_test!
        #   end
        # end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '500', 'internal server error' do
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '500', 'internal server error' do
        #     run_test!
        #   end
        # end
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
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '200', 'child updated' do
          let(:child) { { "child": params.merge("full_name": 'Hermione Granger') } }
          run_test! do |response|
            expect(response).to match_response_schema('child')
            expect(response.parsed_body['full_name']).to eq('Hermione Granger')
          end
        end

        response '422', 'child cannot be updated' do
          let(:child) { { "child": { "full_name": nil } } }
          run_test!
        end

        response '404', 'child not found' do
          let(:id) { 'invalid' }
          let(:child) { { "child": params } }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '401', 'not authorized' do
        #     run_test!
        #   end
        # end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '500', 'internal server error' do
          let(:child) { { "child": params } }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '500', 'internal server error' do
        #     run_test!
        #   end
        # end
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
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '204', 'child deleted' do
          run_test!
        end

        response '404', 'child not found' do
          let(:id) { 'invalid' }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '401', 'not authorized' do
        #     run_test!
        #   end
        # end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '500', 'internal server error' do
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '500', 'internal server error' do
        #     run_test!
        #   end
        # end
      end
    end
  end
end
