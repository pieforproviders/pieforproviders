# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisAttendanceRateCalculator, type: :service do
  let!(:multiple_child_family_approval) { create(:approval, create_children: false, effective_on: Date.parse('December 1st, 2020', expires_on: nil)) }
  let!(:multiple_child_family) { create_list(:child, 2, approvals: [multiple_child_family_approval]) }
  let!(:single_child_family_approval) { create(:approval, create_children: false, effective_on: Date.parse('December 1st, 2020', expires_on: nil)) }
  let!(:single_child_family) { create(:child, approvals: [single_child_family_approval]) }

  # TODO: change this to #call describe and break down contexts
  describe '#call' do
    before do
      travel_to Date.parse('December 11th, 2020')
      create(:illinois_approval_amount,
             part_days_approved_per_week: 2,
             full_days_approved_per_week: 0,
             child_approval: single_child_family.child_approvals.first,
             month: Time.current)
      create_list(:illinois_part_day_attendance, 3, child_approval: single_child_family.child_approvals.first)
      multiple_child_family_approval.children.each do |child|
        create(:illinois_approval_amount,
               part_days_approved_per_week: 2,
               full_days_approved_per_week: 0,
               child_approval: child.child_approvals.first,
               month: Time.current)
        create_list(:illinois_part_day_attendance, 3, child_approval: child.child_approvals.first)
      end
    end
    after { travel_back }

    it 'calculates the rate correctly for single-child families and multiple-child families' do
      expect(described_class.new(single_child_family, Time.current).call).to eq(0.3)
      expect(described_class.new(multiple_child_family_approval.children.first, Time.current).call).to eq(0.3)
      expect(described_class.new(multiple_child_family_approval.children.last, Time.current).call).to eq(0.3)
    end
  end
end
