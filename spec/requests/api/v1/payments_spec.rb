# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'payments API', type: :request do
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
  let!(:agency_params) do
    {
      "name": 'Agency 1',
      "state": 'IL'
    }
  end
  let(:agency_id) { Agency.create!(agency_params).id }
  let(:business_params) do
    {
      "name": 'Happy Hearts Child Care',
      "category": 'licensed_center_single',
      "user_id": user_id
    }
  end
  let(:business_id) { Business.create!(business_params).id }
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
  let(:site_id) { Site.create!(site_params).id }
  let!(:payment_params) do
    {
      "agency_id": agency_id,
      "amount_cents": '123400',
      "care_finished_on": '2020-06-01',
      "care_started_on": '2020-01-01',
      "discrepancy_cents": '7890',
      "paid_on": '2020-07-07',
      "site_id": site_id
    }
  end

  path '/api/v1/payments' do
    get 'lists all payments for a user' do
      tags 'payments'
      produces 'application/json'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'payments found' do
            run_test! do
              expect(response).to match_response_schema('payments')
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

    post 'creates a payment' do
      tags 'payments'
      consumes 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      parameter name: :payment, in: :body, schema: {
        '$ref' => '#/definitions/createPayment'
      }

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '201', 'payment created' do
            let(:payment) { { "payment": payment_params } }
            run_test! do
              expect(response).to match_response_schema('payment')
            end
          end
          response '422', 'invalid request' do
            let(:payment) { { "payment": { "title": 'whatever' } } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end
      end
    end
  end

  path '/api/v1/payments/{slug}' do
    parameter name: :slug, in: :path, type: :string
    let(:slug) { Payment.create!(payment_params).slug }

    get 'retrieves a payment' do
      tags 'payments'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'payment found' do
            run_test! do
              expect(response).to match_response_schema('payment')
            end
          end

          response '404', 'payment not found' do
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

    put 'updates a payment' do
      tags 'payments'
      consumes 'application/json', 'application/xml'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :payment, in: :body, schema: {
        '$ref' => '#/definitions/updatePayment'
      }
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '200', 'payment updated' do
            let(:payment) { { "payment": payment_params.merge("amount_cents": 10_000) } }
            run_test! do
              expect(response).to match_response_schema('payment')
              expect(response.parsed_body['amount_cents']).to eq(10_000)
            end
          end

          response '422', 'payment cannot be updated' do
            let(:payment) { { "payment": { "agency_id": nil } } }
            run_test!
          end

          response '404', 'payment not found' do
            let(:slug) { 'invalid' }
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '401', 'not authorized' do
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end
      end

      context 'on the wrong api version' do
        include_context 'incorrect api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '500', 'internal server error' do
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end

        context 'when not authenticated' do
          response '500', 'internal server error' do
            let(:payment) { { "payment": payment_params } }
            run_test!
          end
        end
      end
    end

    delete 'deletes a payment' do
      tags 'payments'
      produces 'application/json', 'application/xml'
      parameter name: 'Accept', in: :header, type: :string, default: 'application/vnd.pieforproviders.v1+json'
      # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
      # security [{ token: [] }]

      context 'on the right api version' do
        include_context 'correct api version header'
        context 'when authenticated' do
          include_context 'authenticated user'
          response '204', 'payment deleted' do
            run_test!
          end

          response '404', 'payment not found' do
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
