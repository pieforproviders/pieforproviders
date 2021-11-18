# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDayBlueprint do
  let(:service_day) { create(:attendance).service_day }
  let(:blueprint) { described_class.render(service_day) }

  it 'returns the correct fields' do
    expect(JSON.parse(blueprint).keys).to contain_exactly(
      'attendances',
      'id',
      'child_id',
      'date',
      'tags',
      'total_time_in_care'
    )
  end
end
