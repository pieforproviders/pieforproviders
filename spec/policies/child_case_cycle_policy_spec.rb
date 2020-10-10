# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildCaseCyclePolicy do
  subject { described_class }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }
  let(:child) { create(:child) }
  let(:user) { child.user }
  let(:case_cycle) { create(:case_cycle, user: user) }
  let(:subsidy_rule) { create(:subsidy_rule, state: child.business.county.state, county: child.business.county) }
  let(:child_case_cycle) { create(:child_case_cycle, child: child, case_cycle: case_cycle, subsidy_rule: subsidy_rule) }
  let(:child_case_cycle_attributes) { child_case_cycle.attributes.except('id') }
  let(:valid_child_case_cycle) { ChildCaseCycle.new(child_case_cycle_attributes) }

  permissions :create? do
    it 'grants access if record is invalid' do
      expect(subject).to permit(user, ChildCaseCycle.new)
    end

    it 'grants access to admins' do
      expect(subject).to permit(admin, valid_child_case_cycle)
    end

    it 'grants access to owners' do
      expect(subject).to permit(user, valid_child_case_cycle)
    end

    it 'denies access to non-owners' do
      expect(subject).not_to permit(non_owner, valid_child_case_cycle)
    end
  end

  describe ChildCaseCyclePolicy::Scope do
    context 'admin user' do
      it 'returns all child case cycles' do
        child_case_cycles = ChildCaseCyclePolicy::Scope.new(admin, ChildCaseCycle).resolve
        expect(child_case_cycles).to match_array([child_case_cycle])
      end
    end

    context 'owner user' do
      it "returns the user's case cycles" do
        child_case_cycles = ChildCaseCyclePolicy::Scope.new(user, ChildCaseCycle).resolve
        expect(child_case_cycles).to match_array([child_case_cycle])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        child_case_cycles = ChildCaseCyclePolicy::Scope.new(non_owner, ChildCaseCycle).resolve
        expect(child_case_cycles).to be_empty
      end
    end
  end
end
