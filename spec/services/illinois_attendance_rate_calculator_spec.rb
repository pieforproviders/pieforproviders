# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisAttendanceRateCalculator, type: :service do
  let!(:multiple_child_family_approval) { create(:approval, create_children: false) }
  let!(:single_child_family_approval) do
    create(:approval, create_children: false, effective_on: multiple_child_family_approval.effective_on)
  end
  let!(:single_child_family) { create(:child, approvals: [single_child_family_approval]) }

  # TODO: change this to #call describe and break down contexts
  describe '#call' do
    before do
      create_list(:child, 2, approvals: [multiple_child_family_approval])
      travel_to multiple_child_family_approval.effective_on.at_end_of_month + 10.days
      create(:illinois_approval_amount,
             part_days_approved_per_week: 2,
             full_days_approved_per_week: 0,
             child_approval: single_child_family.child_approvals.first,
             month: Time.current)
      3.times do |idx|
        service_day = create(:service_day,
                             date: Time.current.in_time_zone(Child.first.timezone).prev_occurring(:monday) + idx.days,
                             child: single_child_family)
        create(:illinois_part_day_attendance,
               service_day: service_day,
               child_approval: single_child_family.child_approvals.first,
               check_in: service_day.date + 3.hours)
      end
      multiple_child_family_approval.children.each do |child|
        create(:illinois_approval_amount,
               part_days_approved_per_week: 2,
               full_days_approved_per_week: 0,
               child_approval: child.child_approvals.first,
               month: Time.current)
        3.times do |idx|
          service_day = create(:service_day,
                               date: Time.current.in_time_zone(Child.first.timezone).prev_occurring(:monday) + idx.days,
                               child: child)
          create(:illinois_part_day_attendance,
                 service_day: service_day,
                 child_approval: child.child_approvals.first,
                 check_in: service_day.date + 3.hours)
        end
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
