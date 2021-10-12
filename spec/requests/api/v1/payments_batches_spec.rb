# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::PaymentsBatches', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business) { create(:business, :nebraska, user: logged_in_user) }
  let!(:approval_sept) do
    create(:approval, effective_on: Date.parse('2021-09-01'), business: business, create_children: false)
  end
  let!(:approval_oct) do
    create(:approval, effective_on: Date.parse('2021-10-01'), business: business, create_children: false)
  end
  let!(:child) { create(:child, approvals: [approval_sept, approval_oct], business: business) }

  include_context 'with correct api version header'

  before do
    sign_in logged_in_user
  end

  describe 'POST /api/v1/payments_batches' do
    let(:params) do
      {
        payments_batch: [
          {
            month: '2021-10-30',
            amount: 10.30,
            child_id: child.id
          },
          {
            month: '2021-09-30',
            amount: 9.30,
            child_id: child.id
          }
        ]
      }
    end

    it 'creates a payments for children' do
      post '/api/v1/payments_batches', params: params, headers: headers
      parsed_response = JSON.parse(response.body)
      output_payment1, output_payment2 = parsed_response['payments']
      input_payment1, input_payment2 = params[:payments_batch]
      expect(output_payment1['child_approval_id'])
        .to eq(Child.find(input_payment1[:child_id])
                    .active_child_approval(Date.parse(input_payment1[:month].to_s))
                    .id)
      expect(output_payment1['amount']).to eq(input_payment1[:amount].to_s)

      expect(output_payment2['child_approval_id'])
        .to eq(Child.find(input_payment2[:child_id])
                    .active_child_approval(Date.parse(input_payment2[:month].to_s))
                    .id)
      expect(output_payment2['amount']).to eq(input_payment2[:amount].to_s)
    end
  end
end
