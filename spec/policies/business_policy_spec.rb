# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessPolicy do
  subject { described_class }

  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }
  let(:business) { create(:business, zipcode: '60606', county: 'Cook', user: user) }
  let(:inactive_business) do
    create(:business, zipcode: '60606', county: 'Cook', name: 'Test Daycare Center', user: user, active: false)
  end

  describe BusinessPolicy::Scope do
    context 'admin user' do
      it 'returns all businesses' do
        businesses = described_class.new(admin, Business).resolve
        expect(businesses).to match_array([business, inactive_business])
      end
    end

    context 'owner user' do
      it "returns the user's active businesses" do
        businesses = described_class.new(user, Business).resolve
        expect(businesses).to match_array([business])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        businesses = described_class.new(non_owner, Business).resolve
        expect(businesses).to be_empty
      end
    end
  end
end
