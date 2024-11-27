# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisAttendanceRiskCalculator, type: :service do
  describe '#elapsed_eligible_days' do
    it 'calculate elapsed eligible days for child with attended info' do
      business = create(:business)
      child = create(:child_in_illinois)
      create(:child_business, child:, business:)
      date = Date.new(2024, 12, 20)
      eligible_days_in_week = 5
      elapsed_weeks = 3
      elapsed_eligible_days = eligible_days_in_week * elapsed_weeks
      risk_calculator_elapsed_days = described_class.new(child, date).send(:elapsed_eligible_days)

      expect(risk_calculator_elapsed_days).to eq(elapsed_eligible_days)
    end
  end

  describe '#attended_days' do
    it 'calculate attended days until given date' do
      business = create(:business)
      child = create(:child_in_illinois, businesses: [business])
      date = Time.current
      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child:)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child.active_child_approval(attendance_date)
      )

      perform_enqueued_jobs

      full_days = child.service_days.for_month(date).map(&:full_time).compact.reduce(:+) || 0
      part_days = child.service_days.for_month(date).map(&:part_time).compact.reduce(:+) || 0
      total_days = full_days + part_days
      attendance_service = described_class.new(child, date)

      expect(attendance_service.send(:attended_days)).to eq(total_days)
    end
  end

  describe '#attendance_rate_until_date' do
    it 'caculate attendance rate until given date' do
      business = create(:business)
      child = create(:child_in_illinois, businesses: [business])
      date = Time.current
      attendance_date = Time.current.at_beginning_of_month
      service_full_day = create(:service_day, child:)
      create(
        :illinois_full_day_attendance,
        service_day: service_full_day,
        child_approval: child.active_child_approval(attendance_date)
      )
      elapsed_days = date - Time.current.at_beginning_of_month
      full_days = child.service_days.for_month(date).map(&:full_time).compact.reduce(:+) || 0
      part_days = child.service_days.for_month(date).map(&:part_time).compact.reduce(:+) || 0
      total_attended_days = full_days + part_days
      attendance_service = described_class.new(child, date)

      expect(attendance_service.send(:attendance_rate_until_date)).to eq(total_attended_days.to_f / elapsed_days)
    end
  end

  describe '#risk_label' do
    it 'return not_enough_info label when there is no attendances' do
      business = create(:business)
      child = create(:child_in_illinois, businesses: [business])
      date = Time.current.at_end_of_month
      attendance_rate_until_date = described_class.new(child, date).call
      expect(attendance_rate_until_date).to eq('not_enough_info')
    end

    it 'return not_enough_info label with attendance info but less than halfway through month' do
      travel_to Time.current.at_beginning_of_month + rand(2..14).days
      business = create(:business)
      child = create(:child_in_illinois, businesses: [business])
      date = Time.current.at_beginning_of_month + 5.days

      3.times do |idx|
        service_day = create(:service_day,
                             date: date.in_time_zone(Child.first.timezone).prev_occurring(:monday) + idx.days,
                             child:)
        create(:illinois_part_day_attendance,
               service_day:,
               child_approval: child.child_approvals.first,
               check_in: service_day.date + 3.hours)
      end

      perform_enqueued_jobs

      attendance_service = described_class.new(child, Time.current)

      expect(attendance_service.call).to eq('not_enough_info')
    end

    it 'return at_risk label when attended rate is below treshold' do
      travel_to Time.current.at_beginning_of_month + rand(15..28).days
      business = create(:business)
      child = create(:child_in_illinois, businesses: [business])
      date = Time.current.at_beginning_of_month

      7.times do |idx|
        service_day = create(:service_day,
                             date: date.in_time_zone(Child.first.timezone) + idx.days,
                             child:)
        create(:illinois_part_day_attendance,
               service_day:,
               child_approval: child.child_approvals.first,
               check_in: service_day.date + 3.hours)
      end

      perform_enqueued_jobs

      attendance_service = described_class.new(child, Time.current)
      expect(attendance_service.call).to eq('at_risk')
    end

    it 'return on_track label when attended rate is above treshold' do
      rand_num = rand(14..28)
      travel_to Time.current.at_beginning_of_month + rand_num.days
      business = create(:business)
      child = create(:child_in_illinois, businesses: [business])
      date = Time.current.at_beginning_of_month
      amount_of_attendances = 11 + rand_num

      amount_of_attendances.times do |idx|
        service_day = create(:service_day,
                             date: date.in_time_zone(Child.first.timezone) + idx.days,
                             child:)
        create(:illinois_part_day_attendance,
               service_day:,
               child_approval: child.child_approvals.first,
               check_in: service_day.date + 3.hours)
      end

      perform_enqueued_jobs

      attendance_service = described_class.new(child, Time.current)
      expect(attendance_service.call).to eq('on_track')
    end
  end
end
