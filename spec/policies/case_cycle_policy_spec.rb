# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseCyclePolicy do
  subject { described_class }
  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }
  let(:case_cycle) { create(:case_cycle, user: user) }

  describe CaseCyclePolicy::Scope do
    context 'admin user' do
      it 'returns all case cycles' do
        case_cycles = CaseCyclePolicy::Scope.new(admin, CaseCycle).resolve
        expect(case_cycles).to match_array([case_cycle])
      end
    end

    context 'owner user' do
      it "returns the user's case cycles" do
        case_cycles = CaseCyclePolicy::Scope.new(user, CaseCycle).resolve
        expect(case_cycles).to match_array([case_cycle])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        case_cycles = CaseCyclePolicy::Scope.new(non_owner, CaseCycle).resolve
        expect(case_cycles).to be_empty
      end
    end
  end
end
