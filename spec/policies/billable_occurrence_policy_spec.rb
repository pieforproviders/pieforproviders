# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillableOccurrencePolicy do
  subject { described_class }
  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:business) { create(:business, user: user) }
  let(:admin) { create(:admin) }
  let(:child) { create(:child, business: business) }
  let(:billable_occurrence) { create(:billable_attendance, child_approval: child.child_approvals[0]) }

  describe BillableOccurrencePolicy::Scope do
    context 'admin user' do
      it 'returns all billable occurrences' do
        billable_occurrences = BillableOccurrencePolicy::Scope.new(admin, BillableOccurrence).resolve
        expect(billable_occurrences).to match_array([billable_occurrence])
      end
    end

    context 'owner user' do
      it 'returns the billable occurrences associated to the user' do
        billable_occurrences = BillableOccurrencePolicy::Scope.new(user, BillableOccurrence).resolve
        expect(billable_occurrences).to match_array([billable_occurrence])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        billable_occurrences = BillableOccurrencePolicy::Scope.new(non_owner, BillableOccurrence).resolve
        expect(billable_occurrences).to be_empty
      end
    end
  end
end
