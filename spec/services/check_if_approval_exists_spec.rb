# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckIfApprovalExists do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:non_owner_business) { create(:business, zipcode: created_business.zipcode, county: created_business.county) }
  let!(:child_params) do
    {
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [attributes_for(:approval)]
    }
  end
  let(:count) { 2 }
  let(:owner) { user }
  let(:owner_attributes) { { business: created_business } }
  let(:non_owner_attributes) { { business: non_owner_business } }
  let(:child) { Child.create! child_params }
  let(:approval) { child.approvals.first }
  let!(:child_params2) do
    {
      "full_name": 'Naman Patil',
      "date_of_birth": '2010-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [
        {
          "case_number": approval.case_number,
          "effective_on": approval.effective_on,
          "expires_on": approval.expires_on,
          "copay": 20_000,
          "copay_frequency": "monthly"
        }]
    }
  end
  let!(:child2) { Child.new child_params2 }

  context "approval was found" do
    it "does not create an approval" do
      # 2 children with the same case number/expires/effective
      # and child2 does not have an approval created, approval is associated
      # expect 2 childre, 2 child approvals, 1 approval
      binding.pry
      described_class.new(child2).call
    end
  end
  # ApprovalCreatorOrAssociator - name

  context "approval was not found - case number different" do
      # 2 children with different case number/expires/effective
      # and child2  approval created, approval is not associated
      # expect 2 children, 2 child approvals, 2 approvals
    it "creates an approval" do

    end

    # 2 children same case number, different dates -> 2 approvals
    it "creates an approval" do

    end

    # TODO renewals
  end
end
