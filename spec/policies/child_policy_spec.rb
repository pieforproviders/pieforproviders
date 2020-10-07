# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildPolicy do
  subject { described_class }
  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }
  let(:child) { create(:child, user: user) }

  describe ChildPolicy::Scope do
    context 'admin user' do
      it 'returns all children' do
        children = ChildPolicy::Scope.new(admin, Child).resolve
        expect(children).to match_array([child])
      end
    end

    context 'owner user' do
      it 'returns the children associated to the user' do
        children = ChildPolicy::Scope.new(user, Child).resolve
        expect(children).to match_array([child])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        children = ChildPolicy::Scope.new(non_owner, Child).resolve
        expect(children).to be_empty
      end
    end
  end
end
