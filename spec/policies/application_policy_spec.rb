# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject { described_class }
  let(:user) { create(:confirmed_user) }
  let(:admin) { create(:admin) }
  let(:non_owner) { create(:confirmed_user) }
  let(:business) { create(:business, user: user) }

  it 'raises an exception if user is nil' do
    expect { ApplicationPolicy.new(nil, business) }.to raise_error(Pundit::NotAuthorizedError)
  end

  permissions :index?, :create? do
    it 'grants access to all users' do
      expect(subject).to permit(admin)
      expect(subject).to permit(user)
    end
  end

  permissions :update?, :destroy? do
    it 'grants access to admins' do
      expect(subject).to permit(admin, business)
    end

    it 'grants access to owners' do
      expect(subject).to permit(user, business)
    end

    it 'denies access to non-owners' do
      expect(subject).not_to permit(non_owner, business)
    end
  end

  describe ApplicationPolicy::Scope do
    it 'raises an exception if user is nil' do
      expect { ApplicationPolicy::Scope.new(nil, Business) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
