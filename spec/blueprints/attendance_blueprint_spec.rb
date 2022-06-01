# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceBlueprint do
  let(:service_day) { create(:service_day) }
  let(:attendance) { create(:attendance, service_day: service_day, check_in: service_day.date + 2.hours) }
  let(:blueprint) { described_class.render(attendance) }
  let(:blueprint_with_child) { described_class.render(attendance, view: :with_child) }

  it 'returns the correct fields' do
    expect(JSON.parse(blueprint).keys).to contain_exactly(
      'id',
      'check_in',
      'check_out',
      'time_in_care',
      'child_approval_id'
    )
  end

  it 'returns the correct fields with child' do
    expect(JSON.parse(blueprint_with_child).keys).to contain_exactly(
      'id',
      'check_in',
      'check_out',
      'child',
      'time_in_care',
      'child_approval_id'
    )
  end
end
