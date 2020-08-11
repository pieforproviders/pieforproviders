# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'payments API', type: :request do
  let(:user_id) { build(:confirmed_user).id }
  let(:agency_id) { create(:agency).id }
  let(:business_id) { build(:business).id }
  let(:site_id) { create(:site).id }
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
          response '201', 'payment created' do
            let(:payment) do
              payment_params.delete('discrepancy_cents')
              { "payment": payment_params }
            end
            run_test! do
              expect(response).to match_response_schema('payment')
            end
          end
          response '422', 'invalid request' do
            let(:payment) { { "payment": { "title": 'whatever' } } }
            run_test!
          end
          response '422', 'invalid request' do
            let(:payment) do
              payment_params.delete(:amount_cents)
              { "payment": payment_params }
            end
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
          response '200', 'payment updated' do
            let(:payment) { { "payment": { "amount_cents": 999 } } }
            run_test! do
              expect(response).to match_response_schema('payment')
              expect(response.parsed_body['amount_cents']).to eq(999)
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
