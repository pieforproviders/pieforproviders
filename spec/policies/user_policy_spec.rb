# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }
  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }

  permissions :index? do
    it 'grants access to admins' do
      expect(subject).to permit(admin, User)
    end

    it 'denies access to non-admin users' do
      expect(subject).not_to permit(user, User)
    end
  end

  permissions :update?, :destroy? do
    it 'grants access to admins' do
      expect(subject).to permit(admin, user)
    end

    it 'grants access to owners' do
      expect(subject).to permit(user, user)
    end

    it 'denies access to non-owners' do
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
