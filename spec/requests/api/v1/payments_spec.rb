# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'payments API', type: :request do
  # Use confirmed_user so that no confirmation email is sent
  let(:confirmed_user) { create(:confirmed_user) }
  let(:user_id) { confirmed_user.id }
  let(:agency_id) { create(:agency).id }
  let(:created_business) { create(:business, user: confirmed_user) }
  let(:business_id) { created_business.id }
  let!(:payment_params) do
    {
      "agency_id": agency_id,
      "amount_cents": '123400',
      "care_finished_on": '2020-06-01',
      "care_started_on": '2020-01-01',
      "discrepancy_cents": '7890',
      "paid_on": '2020-07-07'
    }
  end

  it_behaves_like 'it lists all items for a user', Payment

  it_behaves_like 'it creates an item', Payment do
    let(:item_params) { payment_params }
  end

  describe 'creates a payment without discrepancy_cents param' do
    it_behaves_like 'it creates an item', Payment do
      let(:item_params) do
        payment_params.delete('discrepancy_cents')
        payment_params
      end
    end
  end

  it_behaves_like 'it retrieves an item for a user', Payment do
    let(:item_params) { payment_params }
  end

  it_behaves_like 'it updates an item', Payment, 'amount_cents', 99_999, nil do
    let(:item_params) { payment_params }
  end

  it_behaves_like 'it deletes an item for a user', Payment do
    let(:item_params) { payment_params }
  end
end
