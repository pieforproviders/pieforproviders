# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  let(:user) { create(:confirmed_user, :nebraska) }
  let(:admin) { create(:admin) }
  let(:non_owner) { create(:confirmed_user) }

  permissions :index? do
    it 'grants access to the index for admins' do
      expect(described_class).to permit(admin, User)
    end

    it 'denies access to the index to non-admin users' do
      expect(described_class).not_to permit(user, User)
    end
  end

  permissions :create? do
    it 'grants access to the create method to everyone' do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(user)
      expect(described_class).to permit(non_owner)
      expect(described_class).to permit('random string?')
    end
  end

  permissions :update?, :destroy? do
    it 'grants access to the update and destroy methods to admins' do
      expect(described_class).to permit(admin, user)
    end

    it 'grants access to the update and destroy methods to owners' do
      expect(described_class).to permit(user, user)
    end

    it 'denies access to the update and destroy methods to non-owners' do
      expect(described_class).not_to permit(non_owner, user)
    end
  end

  describe UserPolicy::Scope do
    context 'when authenticated as an admin' do
      it 'returns only Nebraska users' do
        users = described_class.new(admin, User).resolve
        expect(users).to match_array([user])
      end
    end

    context 'when authenticated as a non-admin user' do
      it 'returns only the user' do
        users = described_class.new(user, User).resolve
        expect(users).to match_array([user])
      end
    end
  end
end
