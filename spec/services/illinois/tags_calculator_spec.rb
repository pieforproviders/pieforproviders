# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::TagsCalculator, type: :service do
  let(:child) { create(:child_in_illinois) }
  let(:service_day) do
    create(:service_day,
           date: Time.current.in_time_zone(Child.first.timezone).prev_occurring(:monday),
           child: child)
  end

  before do
    travel_to child.child_approvals.first.effective_on.at_end_of_month + 10.days
  end

  describe '#tag_partial' do
    it 'returns correct part tag if time in care is less than 5 hours' do
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 6.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:full_day?)).to be(false)
      expect(described_class.new(service_day: service_day).send(:tag_partial)).to eq('1 partDay')
    end
  end

  describe '#tag_full' do
    it 'returns correct 1 full day if time in care is 5 hours' do
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 8.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(false)
      expect(described_class.new(service_day: service_day).send(:full_day?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:tag_full)).to eq('1 daily')
    end

    it 'returns correct 1 full day if time in care is less than 12 hours' do
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 14.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(false)
      expect(described_class.new(service_day: service_day).send(:full_day?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:tag_full)).to eq('1 daily')
    end
  end

  describe '#tag_two_days' do
    it 'returns 2 full days tag if time in care is 17 hours' do
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 20.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(false)
      expect(described_class.new(service_day: service_day).send(:full_day?)).to be(false)
      expect(described_class.new(service_day: service_day).send(:tag_partial)).to be_nil
      expect(described_class.new(service_day: service_day).send(:tag_two_days)).to eq('2 fullDays')
    end
  end

  describe '#full_and_part_day' do
    it 'returns 1 full day and 1 part day if time in care is 12 hours' do
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 15.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:full_day?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:tag_partial)).to eq('1 partDay')
      expect(described_class.new(service_day: service_day).send(:tag_full)).to eq('1 daily')
      expect(described_class.new(service_day: service_day).send(:tag_two_days)).to be_nil
    end

    it 'returns 1 full day and 1 part day if time in care is less than 17 hours' do
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 19.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:full_day?)).to be(true)
      expect(described_class.new(service_day: service_day).send(:tag_partial)).to eq('1 partDay')
      expect(described_class.new(service_day: service_day).send(:tag_full)).to eq('1 daily')
      expect(described_class.new(service_day: service_day).send(:tag_two_days)).to be_nil
    end
  end
end
