# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDayBlueprint do
  let(:service_day) { create(:service_day) }
  let(:blueprint) { described_class.render(service_day) }

  it 'returns the correct fields' do
    expect(JSON.parse(blueprint).keys).to contain_exactly(
      'absence_type',
      'attendances',
      'id',
      'child_id',
      'child',
      'date',
      'tags',
      'total_time_in_care',
      'full_time',
      'part_time',
      'state'
    )
  end
end
