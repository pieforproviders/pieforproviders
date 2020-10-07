# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'case_cycles API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:case_cycle_params) do
    {
      "case_number": '123-45-6789',
      "copay_cents": '123400',
      "copay_frequency": 'weekly',
      "status": 'pending',
      "submitted_on": '2020-08-12',
      "user_id": user.id
    }
  end

  it_behaves_like 'it lists all items for a user', CaseCycle

  it_behaves_like 'it creates an item', CaseCycle do
    let(:item_params) { case_cycle_params }
  end

  it_behaves_like 'admins and resource owners can retrieve an item', CaseCycle do
    let(:item_params) { case_cycle_params }
    let(:item) { CaseCycle.create! case_cycle_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can update an item', CaseCycle, 'effective_on', '2020-06-18', 7 do
    let(:item_params) { case_cycle_params }
    let(:item) { CaseCycle.create! case_cycle_params }
    let(:owner) { user }
  end

  it_behaves_like 'admins and resource owners can delete an item', CaseCycle do
    let(:item) { CaseCycle.create! case_cycle_params }
    let(:owner) { user }
  end
end
