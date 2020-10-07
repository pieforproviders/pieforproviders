# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessPolicy do
  subject { described_class }
  let(:user) { create(:confirmed_user) }
  let!(:zipcode) { create(:zipcode) }
  let(:non_owner) { create(:confirmed_user) }
  let(:admin) { create(:admin) }
  let(:business) { create(:business, zipcode: zipcode, county: zipcode.county, user: user) }
  let(:inactive_business) { create(:business, zipcode: zipcode, county: zipcode.county, name: 'Test Daycare Center', user: user, active: false) }

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
