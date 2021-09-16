# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }

  permissions :index? do
    it 'grants access to the index for admins' do
      expect(subject).to permit(admin, User)
    end

    it 'denies access to the index to non-admin users' do
      expect(subject).not_to permit(user, User)
    end
  end

  permissions :create? do
    it 'grants access to the create method to everyone' do
      expect(subject).to permit(admin)
      expect(subject).to permit(user)
      expect(subject).to permit(non_owner)
      expect(subject).to permit('random string?')
    end
  end

  permissions :update?, :destroy? do
    it 'grants access to the update and destroy methods to admins' do
      expect(subject).to permit(admin, user)
    end

    it 'grants access to the update and destroy methods to owners' do
      expect(subject).to permit(user, user)
    end

    it 'denies access to the update and destroy methods to non-owners' do
      expect(subject).not_to permit(non_owner, user)
    end
  end

  describe UserPolicy::Scope do
    context 'admin user' do
      it 'returns all users' do
        users = UserPolicy::Scope.new(admin, User).resolve
        expect(users).to match_array([user, non_owner, admin])
      end
    end

    context 'non-admin user' do
      it 'returns only the user' do
        users = UserPolicy::Scope.new(user, User).resolve
        expect(users).to match_array([user])
      end
    end
  end
end
