# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'businesses API', type: :request do
  let!(:user_params) do
    {
      "email": 'fake_email@fake_email.com',
      "full_name": 'Oliver Twist',
      "greeting_name": 'Oliver',
      "language": 'English',
      "mobile": '912-444-5555',
      "phone": '912-444-5555',
      "organization": 'Society for the Promotion of Elfish Welfare',
      "service_agreement_accepted": 'true',
      "timezone": 'Central Time (US & Canada)'
    }
  end
  let(:user_id) { User.create(user_params).id }
  let!(:business_params) do
    {
      "name": 'Happy Hearts Childcare',
      "category": 'licensed_center_single',
      "user_id": user_id
    }
  end

  path '/api/v1/businesses' do
    get 'lists all businesses for a user' do
      tags 'businesses'
      produces 'application/json'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '200', 'businesses found' do
          run_test! do
            expect(response).to match_response_schema('businesses')
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

    post 'creates a business' do
      tags 'businesses'
      consumes 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      parameter name: :business, in: :body, schema: {
        '$ref' => '#/definitions/createBusiness'
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '201', 'business created' do
          let(:business) { { "business": business_params } }
          run_test! do
            expect(response).to match_response_schema('business')
          end
        end
        response '422', 'invalid request' do
          let(:business) { { "business": { "title": 'whatever' } } }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '201', 'business created' do
        #     let(:business) { { "business": business_params } }
        #     run_test! do
        #       expect(response).to match_response_schema('business')
        #     end
        #   end
        #   response '422', 'invalid request' do
        #     let(:business) { { "business": { "title": 'foo' } } }
        #     run_test!
        #   end
        # end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        # context 'when authenticated' do
        # include_context 'authenticated user'
        response '500', 'internal server error' do
          let(:business) { { "business": business_params } }
          run_test!
        end
        # end

        # context 'when not authenticated' do
        #   include_context 'unauthenticated user'
        #   response '500', 'internal server error' do
        #     let(:business) { { "business": business_params } }
        #     run_test!
        #   end
        # end
      end
    end
  end

  path '/api/v1/businesses/{slug}' do
    parameter name: :slug, in: :path, type: :string
    let(:slug) { Business.create!(business_params).slug }
    get 'retrieves a business' do
      tags 'businesses'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '200', 'business found' do
          run_test! do
            expect(response).to match_response_schema('business')
          end
        end

        response '404', 'business not found' do
          let(:slug) { 'invalid' }
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
    put 'updates a business' do
      tags 'businesses'
      consumes 'application/json', 'application/xml'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :business, in: :body, schema: {
        '$ref' => '#/definitions/updateBusiness'
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '200', 'business updated' do
          let(:business) { { "business": business_params.merge("name": 'Hogwarts School') } }
          run_test! do
            expect(response).to match_response_schema('business')
            # expect(response.parsed_body['name']).to eq('Hogwarts School')
          end
        end

        response '422', 'business cannot be updated' do
          let(:business) { { "business": { "name": nil } } }
          run_test!
        end

        response '404', 'business not found' do
          let(:slug) { 'invalid' }
          let(:business) { { "business": business_params } }
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
          let(:business) { { "business": business_params } }
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
    delete 'deletes a business' do
      tags 'businesses'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        # context 'when authenticated' do
        #   include_context 'authenticated user'
        response '204', 'business deleted' do
          run_test!
        end

        response '404', 'business not found' do
          let(:slug) { 'invalid' }
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
