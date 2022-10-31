# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Illinois::DashboardCaseBlueprint do
  include_context 'with illinois child created for dashboard'

  before do
    # first dashboard view date is Jul 8th, 2021 at 4pm
    travel_to attendance_date.in_time_zone(child.timezone) + 4.days + 16.hours
  end

  after { travel_back }

  # FIXME: Child is ot being created with approvals and it breaks while creating the factory
  xit 'includes the child name and all cases' do
    expect(
      JSON.parse(described_class.render(
                   Illinois::DashboardCase.new(
                     child: child,
                     filter_date: Time.current,
                     attended_days: child.service_days.with_attendances.non_absences
                   )
                 )).keys
    ).to contain_exactly(
      'case_number',
      'guaranteed_revenue'
    )
  end
end
