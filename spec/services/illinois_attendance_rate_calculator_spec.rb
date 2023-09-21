# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisAttendanceRateCalculator, type: :service do
  let!(:multiple_child_family_approval) { create(:approval, create_children: false) }
  let!(:single_child_family_approval) do
    create(:approval, create_children: false, effective_on: multiple_child_family_approval.effective_on)
  end
  let!(:single_child_family) { create(:child, approvals: [single_child_family_approval]) }
  let!(:child_with_missing_info) do
    create(
      :child,
      approvals:
        [
          create(:approval, create_children: false, effective_on: multiple_child_family_approval.effective_on)
        ]
    )
  end

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
               service_day:,
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
                               child:)
          create(:illinois_part_day_attendance,
                 service_day:,
                 child_approval: child.child_approvals.first,
                 check_in: service_day.date + 3.hours)
        end
      end
      create(:illinois_approval_amount,
             part_days_approved_per_week: nil,
             full_days_approved_per_week: nil,
             child_approval: child_with_missing_info.child_approvals.first,
             month: Time.current)
      perform_enqueued_jobs
    end

    after { travel_back }

    it 'calculates the rate correctly for single-child families and multiple-child families' do
      february = 2
      attendances = 3
      approved_attendances_times_weeks_in_month = 2 * (Time.current.month == february ? 4 : 5)
      expected_rate = attendances / approved_attendances_times_weeks_in_month.to_f
      expect(described_class.new(single_child_family, Time.current).call).to eq(expected_rate)
      expect(described_class.new(multiple_child_family_approval.children.first, Time.current).call)
        .to eq(expected_rate)
      expect(described_class.new(multiple_child_family_approval.children.last, Time.current).call)
        .to eq(expected_rate)
    end

    it 'calculates the rate correctly without part and full day info on approval' do
      february = 2
      attendances = 3
      approved_attendances_times_weeks_in_month = 2 * (Time.current.month == february ? 4 : 5)
      expected_rate = attendances / approved_attendances_times_weeks_in_month.to_f
      expect(described_class.new(child_with_missing_info, Time.current).call).to eq(0)
      expect(described_class.new(multiple_child_family_approval.children.first, Time.current).call)
        .to eq(expected_rate)
      expect(described_class.new(multiple_child_family_approval.children.last, Time.current).call)
        .to eq(expected_rate)
    end
  end

  describe '#sum_eligible_days' do
    before { travel_to '2022-10-24'.to_date }

    after  { travel_back }

    let!(:child_approval) do
      create(:approval, create_children: false, effective_on: 3.months.ago)
    end
    let!(:child) { create(:child, approvals: [child_approval]) }

    context 'when only part days are approved' do
      it 'sums eligible days for part days only' do
        create(
          :illinois_approval_amount,
          part_days_approved_per_week: 4,
          full_days_approved_per_week: 0,
          child_approval: child.child_approvals.first,
          month: Time.current
        )

        4.times do |idx|
          service_day = create(
            :service_day,
            date: Time.current.in_time_zone(child.timezone).prev_occurring(:monday) + idx.days,
            child:
          )
          create(
            :illinois_part_day_attendance,
            service_day:,
            child_approval: child.child_approvals.first,
            check_in: service_day.date + 3.hours
          )
        end
        perform_enqueued_jobs
        february = 2
        days_approved_part_time = 4
        approved_attendances_times_weeks_in_month = days_approved_part_time * (Time.current.month == february ? 4 : 5)
        expect(described_class.new(child, Time.current).send(:sum_eligible_days, child))
          .to eq(approved_attendances_times_weeks_in_month)
      end
    end

    context 'when only full days are approved' do
      it 'sums eligible days for full days only' do
        create(
          :illinois_approval_amount,
          part_days_approved_per_week: 0,
          full_days_approved_per_week: 3,
          child_approval: child.child_approvals.first,
          month: Time.current
        )

        3.times do |idx|
          service_day = create(
            :service_day,
            date: Time.current.in_time_zone(child.timezone).prev_occurring(:monday) + idx.days,
            child:
          )
          create(
            :illinois_part_day_attendance,
            service_day:,
            child_approval: child.child_approvals.first,
            check_in: service_day.date + 3.hours,
            check_out: service_day.date + 9.hours
          )
        end
        perform_enqueued_jobs
        february = 2
        days_approved_full_time = 3
        approved_attendances_times_weeks_in_month = days_approved_full_time * (Time.current.month == february ? 4 : 5)
        expect(described_class.new(child, Time.current).send(:sum_eligible_days, child))
          .to eq(approved_attendances_times_weeks_in_month)
      end
    end

    context 'when part and full days are approved' do
      it 'sums eligible days for part days only' do
        create(
          :illinois_approval_amount,
          part_days_approved_per_week: 4,
          full_days_approved_per_week: 1,
          child_approval: child.child_approvals.first,
          month: Time.current
        )

        4.times do |idx|
          service_day = create(
            :service_day,
            date: Time.current.in_time_zone(child.timezone).prev_occurring(:monday) + idx.days,
            child:
          )
          create(
            :illinois_part_day_attendance,
            service_day:,
            child_approval: child.child_approvals.first,
            check_in: service_day.date + 3.hours
          )
        end

        february = 2
        days_approved_part_time = 4
        perform_enqueued_jobs
        approved_attendances_times_weeks_in_month = days_approved_part_time * (Time.current.month == february ? 4 : 5)
        expect(described_class.new(child, Time.current).send(:sum_eligible_days, child))
          .to eq(approved_attendances_times_weeks_in_month)
      end

      it 'sums eligible days for part days and full days' do
        create(
          :illinois_approval_amount,
          part_days_approved_per_week: 4,
          full_days_approved_per_week: 1,
          child_approval: child.child_approvals.first,
          month: Time.current
        )

        4.times do |idx|
          service_day = create(
            :service_day,
            date: Time.current.in_time_zone(child.timezone).prev_occurring(:monday) + idx.days,
            child:
          )
          create(
            :illinois_part_day_attendance,
            service_day:,
            child_approval: child.child_approvals.first,
            check_in: service_day.date + 3.hours
          )
        end

        2.times do |idx|
          service_day = create(
            :service_day,
            date: 1.week.ago.prev_occurring(:monday) + idx.days,
            child:
          )
          create(
            :illinois_part_day_attendance,
            service_day:,
            child_approval: child.child_approvals.first,
            check_in: service_day.date + 3.hours,
            check_out: service_day.date + 9.hours
          )
        end

        february = 2
        days_approved_part_time = 4
        days_approved_full_time = 1
        perform_enqueued_jobs
        approved_attendances_times_weeks_in_month = days_approved_part_time * (Time.current.month == february ? 4 : 5)
        approved_attendances_times_weeks_in_month += days_approved_full_time * (Time.current.month == february ? 4 : 5)
        expect(described_class.new(child, Time.current).send(:sum_eligible_days, child))
          .to eq(approved_attendances_times_weeks_in_month)
      end
    end
  end

  # describe 'for center licensed business' do
  #   before { travel_to '2022-08-24'.to_date }

  #   after  { travel_back }

  #   let!(:illinois_business_center) { create(:business, :illinois_center) }
  #   let!(:child_approval) do
  #     create(:approval, create_children: false, effective_on: 3.months.ago, business: illinois_business_center)
  #   end
  #   let!(:child_approval2) do
  #     create(:approval, create_children: false, effective_on: 3.months.ago, business: illinois_business_center)
  #   end
  #   let!(:child1) { create(:child, approvals: [child_approval], business: illinois_business_center) }
  #   let!(:child2) { create(:child, approvals: [child_approval2], business: illinois_business_center) }

  #   context 'when multiple children are present' do
  #     it 'sums attendances for all children' do
  #       create(
  #         :illinois_approval_amount,
  #         part_days_approved_per_week: 4,
  #         full_days_approved_per_week: 0,
  #         child_approval: child1.child_approvals.first,
  #         month: Time.current
  #       )

  #       create(
  #         :illinois_approval_amount,
  #         part_days_approved_per_week: 4,
  #         full_days_approved_per_week: 0,
  #         child_approval: child2.child_approvals.first,
  #         month: Time.current
  #       )

  #       4.times do |idx|
  #         service_day = create(
  #           :service_day,
  #           date: Time.current.in_time_zone(child1.timezone).prev_occurring(:monday) + idx.days,
  #           child: child1
  #         )
  #         create(
  #           :illinois_part_day_attendance,
  #           service_day: service_day,
  #           child_approval: child1.child_approvals.first,
  #           check_in: service_day.date + 3.hours
  #         )
  #         service_day = create(
  #           :service_day,
  #           date: Time.current.in_time_zone(child2.timezone).prev_occurring(:monday) + idx.days,
  #           child: child2
  #         )
  #         create(
  #           :illinois_part_day_attendance,
  #           service_day: service_day,
  #           child_approval: child2.child_approvals.first,
  #           check_in: service_day.date + 3.hours
  #         )
  #       end

  #       2.times do |idx|
  #         service_day = create(
  #           :service_day,
  #           date: 1.week.ago.prev_occurring(:monday) + idx.days,
  #           child: child1
  #         )
  #         create(
  #           :illinois_part_day_attendance,
  #           service_day: service_day,
  #           child_approval: child1.child_approvals.first,
  #           check_in: service_day.date + 3.hours
  #         )
  #         service_day = create(
  #           :service_day,
  #           date: 1.week.ago.prev_occurring(:monday) + idx.days,
  #           child: child2
  #         )
  #         create(
  #           :illinois_part_day_attendance,
  #           service_day: service_day,
  #           child_approval: child2.child_approvals.first,
  #           check_in: service_day.date + 3.hours
  #         )
  #       end

  #       perform_enqueued_jobs
  #       february = 2
  #       approved_attendances_times_weeks_in_month = 8 * (Time.current.month == february ? 4 : 5)
  #       expect(described_class.new(child1, Time.current).family_days_attended)
  #         .to eq(12)
  #     end
  #   end
  # end
end
