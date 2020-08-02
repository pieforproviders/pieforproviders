# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'sites API', type: :request do
  let!(:user_params) do
    {
      "email": 'fake_email@fake_email.com',
      "full_name": 'Oliver Twist',
      "greeting_name": 'Oliver',
      "language": 'English',
      "password": 'password1234!',
      "password_confirmation": 'password1234!',
      "phone_number": '912-444-5555',
      "phone_type": 'home',
      "organization": 'Society for the Promotion of Elfish Welfare',
      "service_agreement_accepted": 'true',
      "timezone": 'Central Time (US & Canada)'
    }
  end
  let(:user_id) { User.create(user_params).id }
  let!(:business_params) do
    {
      "name": 'Happy Hearts Child Care',
      "category": 'licensed_center_single',
      "user_id": user_id
    }
  end
  let(:business_id) { Business.create(business_params).id }
  let!(:site_params) do
    {
      "name": 'Evesburg Educational Center',
      "address": '1200 W Marberry Dr',
      "city": 'Gatlinburg',
      "state": 'TN',
      "zip": '12345',
      "county": 'Harrison',
      "qris_rating": '4',
      "business_id": business_id
    }
  end

  path '/api/v1/sites' do
    get 'lists all sites for a user' do
      tags 'sites'
      produces 'application/json'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'sites found' do
            run_test! do
              expect(response).to match_response_schema('sites')
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

    post 'creates a site' do
      tags 'sites'
      consumes 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      parameter name: :site, in: :body, schema: {
        '$ref' => '#/definitions/createSite'
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '201', 'site created' do
            let(:site) { { "site": site_params } }
            run_test! do
              expect(response).to match_response_schema('site')
            end
          end
          response '422', 'invalid request' do
            let(:site) { { "site": { "title": 'whatever' } } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:site) { { "site": site_params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:site) { { "site": site_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:site) { { "site": site_params } }
            run_test!
          end
        end
      end
    end
  end

  path '/api/v1/sites/{slug}' do
    parameter name: :slug, in: :path, type: :string
    let(:slug) { Site.create!(site_params).slug }

    get 'retrieves a site' do
      tags 'sites'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'site found' do
            run_test! do
              expect(response).to match_response_schema('site')
            end
          end

          response '404', 'site not found' do
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

    put 'updates a site' do
      tags 'sites'
      consumes 'application/json', 'application/xml'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :site, in: :body, schema: {
        '$ref' => '#/definitions/updateSite'
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'site updated' do
            let(:site) { { "site": site_params.merge("name": 'Hogwarts School') } }
            run_test! do
              expect(response).to match_response_schema('site')
              expect(response.parsed_body['name']).to eq('Hogwarts School')
            end
          end

          response '422', 'site cannot be updated' do
            let(:site) { { "site": { "name": nil } } }
            run_test!
          end

          response '404', 'site not found' do
            let(:slug) { 'invalid' }
            let(:site) { { "site": site_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:site) { { "site": site_params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:site) { { "site": site_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:site) { { "site": site_params } }
            run_test!
          end
        end
      end
    end

    delete 'deletes a site' do
      tags 'sites'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '204', 'site deleted' do
            run_test!
          end

          response '404', 'site not found' do
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
