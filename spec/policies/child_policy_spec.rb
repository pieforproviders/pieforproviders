# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildPolicy do
  subject { described_class }

  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:business) { create(:business, user: user) }
  let(:admin) { create(:admin) }
  let(:child) { create(:child, business: business) }

  describe ChildPolicy::Scope do
    context 'when authenticated as an admin' do
      it 'returns all children' do
        children = described_class.new(admin, Child).resolve
        expect(children).to match_array([child])
      end
    end

    context 'when logged in as an owner user' do
      it 'returns the children associated to the user' do
        children = described_class.new(user, Child).resolve
        expect(children).to match_array([child])
      end
    end

    context 'when logged in as a non-owner user' do
      it 'returns an empty relation' do
        children = described_class.new(non_owner, Child).resolve
        expect(children).to be_empty
      end
    end
  end
end
