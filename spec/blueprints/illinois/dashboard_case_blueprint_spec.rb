# frozen_string_literal: true

# rubocop:disable RSpec/PendingWithoutReason
require 'rails_helper'

RSpec.describe Illinois::DashboardCaseBlueprint do
  include_context 'with illinois child created for dashboard'

  before do
    # first dashboard view date is Jul 8th, 2022 at 4pm
    travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours
  end

  after { travel_back }

  xit 'includes the child name and all cases' do
    expect(
      JSON.parse(described_class.render(
                   Illinois::DashboardCase.new(
                     child:,
                     filter_date: Time.current,
                     attended_days: child.service_days.with_attendances.non_absences
                   )
                 )).keys
    ).to contain_exactly(
      'attendance_rate',
      'attendance_risk',
      'case_number',
      'full_days_attended',
      'guaranteed_revenue',
      'max_approved_revenue',
      'part_days_attended',
      'potential_revenue'
    )
  end

  xdescribe 'with base attendances' do
    include_context 'with attendances on July 4th and 5th' # Monday, July 4th and Tuesday, July 5th base attendances
    context 'when rendered on July 8th, 2022' do
      before do
        travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours
      end

      after { travel_back }

      # TODO: Implement tests
      xit 'renders correct data' do
        parsed_response = nil
        expect(parsed_response).to be_nil
      end
    end
  end
end
# rubocop:enable RSpec/PendingWithoutReason
