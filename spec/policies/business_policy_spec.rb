# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessPolicy do
  subject { described_class }
  let(:user) { FactoryBot.create(:confirmed_user) }
  let(:non_owner) { FactoryBot.create(:confirmed_user) }
  let(:admin) { FactoryBot.create(:admin) }
  let!(:business) { FactoryBot.create(:business, user: user) }
  let!(:inactive_business) { FactoryBot.create(:business, name: 'Test Daycare Center', user: user, active: false) }

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

  describe BusinessPolicy::Scope do
    context 'admin user' do
      it 'returns all businesses' do
        businesses = BusinessPolicy::Scope.new(admin, Business).resolve
        expect(businesses).to match_array([business, inactive_business])
      end
    end

    context 'owner user' do
      it "returns the user's active businesses" do
        businesses = BusinessPolicy::Scope.new(user, Business).resolve
        expect(businesses).to match_array([business])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        businesses = BusinessPolicy::Scope.new(non_owner, Business).resolve
        expect(businesses).to be_empty
      end
    end
  end
end
