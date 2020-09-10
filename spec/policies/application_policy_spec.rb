# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject { described_class }
  let(:user) { FactoryBot.build_stubbed(:confirmed_user) }
  let(:admin) { FactoryBot.build_stubbed(:admin) }

  permissions :index?, :create? do
    it 'grants access to all users' do
      expect(subject).to permit(admin)
      expect(subject).to permit(user)
    end
  end

  permissions :update?, :destroy? do
    it 'grants access to admins' do
      expect(subject).to permit(admin)
    end

    it 'denies access to non-admin users' do
      expect(subject).not_to permit(user)
    end
  end
end
