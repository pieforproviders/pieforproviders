# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'billable occurrences API', type: :request do
  let(:child) { create(:child) }
  let(:billable_occurrence_params) do
    {
      "child_approval_id": child.child_approvals[0].id,
      "attendance_params": attributes_for(:attendance)
    }
  end

  it_behaves_like 'it lists all items for a user', BillableOccurrence

  it_behaves_like 'it creates an item', BillableOccurrence do
    let(:item_params) { billable_occurrence_params }
  end

  it_behaves_like 'it retrieves an item for a user', BillableOccurrence do
    let(:item_params) { billable_occurrence_params }
  end

  it_behaves_like 'it updates an item', BillableOccurrence, 'attendance_params', { "check_in": Faker::Time.between(from: Time.zone.now - 1.day, to: Time.zone.now).to_s }, nil, true do
    let(:item_params) { billable_occurrence_params }
  end

  it_behaves_like 'it deletes an item for a user', BillableOccurrence do
    let(:item_params) { billable_occurrence_params }
  end
end
