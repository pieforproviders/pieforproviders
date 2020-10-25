# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'billable occurrences API', type: :request do
  let(:child) { create(:child) }
  let(:child2) { create(:child, business: create(:business, user: create(:confirmed_user))) }
  let(:child3) { create(:child, business: child.business) }
  let(:child3id) { child3.id }
  let(:billable_occurrence_params) do
    {
      "child_approval_id": child.child_approvals[0].id,
      "billable_type": 'Attendance',
      "billable_attributes": attributes_for(:attendance)
    }
  end
  let(:count) { 2 }
  let(:owner) { child.business.user }
  let(:owner_attributes) { { child_approval: child.child_approvals[0], billable: create(:attendance) } }
  let(:non_owner_attributes) { { child_approval: child2.child_approvals[0], billable: create(:attendance) } }
  let(:item_params) { billable_occurrence_params }
  let(:item) { BillableOccurrence.create!(owner_attributes) }

  it_behaves_like 'it lists all items for a user', BillableOccurrence

  it_behaves_like 'it creates an item', BillableOccurrence

  it_behaves_like 'admins and resource owners can retrieve an item', BillableOccurrence

  # we're not testing that the item can be updated directly; the only information this
  # model holds is its billable type and id, and child_approval id - if we change the
  # billable type, we'll need to change the billable attributes, and that's a lot of work
  # to maintain basically a stateless record that can just be recreated for the new type.
  # None of these records should be edited directly.

  it_behaves_like 'admins and resource owners can update a nested item', BillableOccurrence, 'billable_attributes', { "check_in": '2014-09-18T19:30:59.000Z' }, nil do
    let(:association) { 'billable' }
  end

  it_behaves_like 'admins and resource owners can delete an item', BillableOccurrence
end
