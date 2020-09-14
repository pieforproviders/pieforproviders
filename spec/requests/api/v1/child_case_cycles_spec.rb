# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'child_case_cycles API', type: :request do
  let(:user) { create(:confirmed_user) }
  let(:case_cycle_id) { create(:case_cycle, user: user).id }
  let(:child_id) { create(:child, user: user).id }
  let(:subsidy_rule_id) { create(:subsidy_rule).id }
  let!(:child_case_cycle_params) do
    {
      "part_days_allowed": 35,
      "full_days_allowed": 15,
      "case_cycle_id": case_cycle_id,
      "child_id": child_id,
      "subsidy_rule_id": subsidy_rule_id
    }
  end

  it_behaves_like 'it lists all items for a user', ChildCaseCycle

  it_behaves_like 'it creates an item', ChildCaseCycle do
    let(:item_params) { child_case_cycle_params }
  end

  it_behaves_like 'it retrieves an item with a slug, for a user', ChildCaseCycle do
    let(:item_params) { child_case_cycle_params }
  end

  it_behaves_like 'it updates an item with a slug', ChildCaseCycle, 'full_days_allowed', 100, 'strings are invalid' do
    let(:item_params) { child_case_cycle_params }
  end

  it_behaves_like 'it deletes an item with a slug, for a user', ChildCaseCycle do
    let(:item_params) { child_case_cycle_params }
  end
end
