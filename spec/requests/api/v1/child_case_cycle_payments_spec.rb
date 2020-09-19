# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'child_case_cycle_payments API', type: :request do
  # Use confirmed_user so that no confirmation email is sent
  let(:confirmed_user) { create(:confirmed_user) }
  let(:user_id) { confirmed_user.id }
  let(:payment_id) { create(:payment).id }
  let(:child_case_cycle_id) { create(:child_case_cycle).id }
  let!(:ccc_payment_params) do
    {
      "payment_id": payment_id,
      "child_case_cycle_id": child_case_cycle_id,
      "amount_cents": '123400',
      "discrepancy_cents": '7890'
    }
  end

  it_behaves_like 'it lists all items for a user', ChildCaseCyclePayment

  it_behaves_like 'it creates an item', ChildCaseCyclePayment do
    let(:item_params) { ccc_payment_params }
  end

  describe 'creates a payment without discrepancy_cents param' do
    it_behaves_like 'it creates an item', ChildCaseCyclePayment do
      let(:item_params) do
        ccc_payment_params.delete('discrepancy_cents')
        ccc_payment_params
      end
    end
  end

  it_behaves_like 'it retrieves an item for a user', ChildCaseCyclePayment do
    let(:item_params) { ccc_payment_params }
  end

  it_behaves_like 'it updates an item', ChildCaseCyclePayment, 'amount_cents', 99_999, nil do
    let(:item_params) { ccc_payment_params }
  end

  it_behaves_like 'it deletes an item for a user', ChildCaseCyclePayment do
    let(:item_params) { ccc_payment_params }
  end
end
