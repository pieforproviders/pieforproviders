# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'case_cycles API', type: :request do
  let(:user_id) { create(:confirmed_user).id }
  let!(:case_cycle_params) do
    {
      "case_number": '123-45-6789',
      "copay_cents": '123400',
      "copay_frequency": 'weekly',
      "status": 'pending',
      "submitted_on": '2020-08-12',
      "user_id": user_id
    }
  end

  it_behaves_like 'it lists all items for a user', CaseCycle

  it_behaves_like 'it creates an item', CaseCycle do
    let(:item_params) { case_cycle_params }
  end

  it_behaves_like 'it retrieves an item with a slug, for a user', CaseCycle do
    let(:item_params) { case_cycle_params }
  end

  it_behaves_like 'it updates an item with a slug', CaseCycle, 'effective_on', '2020-06-18', 7 do
    let(:item_params) { case_cycle_params }
  end

  it_behaves_like 'it deletes an item with a slug, for a user', CaseCycle do
    let(:item_params) { case_cycle_params }
  end
end
