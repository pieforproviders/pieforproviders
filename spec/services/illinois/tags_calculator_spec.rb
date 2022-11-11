# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::TagsCalculator, type: :service do
  let(:child) { create(:child_in_illinois) }
  let(:service_day) do
    create(:service_day,
           date: Time.current.in_time_zone(Child.first.timezone).prev_occurring(:monday),
           child: child)
  end

  describe '#tag_partial' do
    it 'returns correct part tag if time in care is less than 5 hours' do
      travel_to child.child_approvals.first.effective_on.at_end_of_month + 10.days
      create(:illinois_part_day_attendance,
             service_day: service_day,
             child_approval: child.child_approvals.first,
             check_in: service_day.date + 3.hours,
             check_out: service_day.date + 6.hours)
      perform_enqueued_jobs
      service_day.reload
      expect(described_class.new(service_day: service_day).send(:partial?)).to be(true)
    end
  end
end
