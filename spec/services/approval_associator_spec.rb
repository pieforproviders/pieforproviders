# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApprovalAssociator do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:child_params) do
    {
      "full_name": 'Parvati Patil',
      "date_of_birth": '2010-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [attributes_for(:approval)]
    }
  end

  let(:child) { Child.create! child_params }
  let(:approval) { child.approvals.first }
  let(:child2_params) do
    {
      "full_name": 'Kamala Patil',
      "date_of_birth": '2015-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [
        {
          "case_number": approval.case_number,
          "effective_on": approval.effective_on,
          "expires_on": approval.expires_on,
          "copay": 20_000,
          "copay_frequency": 'monthly'
        }
      ]
    }
  end
  let!(:child2) { Child.new child2_params }

  def create_or_associate_approval_for(child)
    described_class.new(child).call
  end

  context 'when you add a child that has the same case number/expires_on/effective_on as another child' do
    it "child 2 gets child 1's approval associated -- 2 children, 2 child approvals, 1 approval" do
      expect { create_or_associate_approval_for(child2) }.to change { Approval.count }.by(0)
      binding.pry
      expect(Approval.count).to eq(1)
      expect(ChildApproval.count).to eq(2)
      expect(Child.count).to eq(2)
      expect(child2.approvals.size).to eq(1)
      expect(child2.approvals.first.id).to eq(approval.id)
    end
  end

  context 'when you add a child that does NOT the same case number/expires_on/effective_on as another child' do
    let!(:child2_params) do
      {
        "full_name": 'Naman Patil',
        "date_of_birth": '2010-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [
          {
            "case_number": 12_345,
            "effective_on": Date.today,
            "expires_on": Date.today,
            "copay": 20_000,
            "copay_frequency": 'monthly'
          }
        ]
      }
    end

    it 'child 2 gets an approval created -- 2 children, 2 child approvals, 2 approvals' do
      expect { create_or_associate_approval_for(child2) }.to change { Approval.count }.by(1)
      expect(Approval.count).to eq(2)
      expect(ChildApproval.count).to eq(2)
      expect(Child.count).to eq(2)
      expect(child2.approvals.first.case_number).to eq(12_345)
    end
  end

  context 'when you add a child that has the same case number but different expires_on/effective_on as another child' do
    let!(:child2_params) do
      {
        "full_name": 'Naman Patil',
        "date_of_birth": '2010-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [
          {
            "case_number": approval.case_number,
            "effective_on": approval.effective_on.next_day,
            "expires_on": approval.expires_on.next_day,
            "copay": 20_000,
            "copay_frequency": 'monthly'
          }
        ]
      }
    end

    it 'child 2 gets an approval created -- 2 children, 2 child approvals, 2 approvals' do
      expect { create_or_associate_approval_for(child2) }.to change { Approval.count }.by(1)
      create_or_associate_approval_for(child2)
      expect(Approval.count).to eq(2)
      expect(ChildApproval.count).to eq(2)
      expect(Child.count).to eq(2)
      expect(child2.approvals.first.case_number).to eq(approval.case_number)
    end
  end
  # TODO: renewals
end
