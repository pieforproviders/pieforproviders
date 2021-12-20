# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceBlueprint do
  let(:attendance) { create(:attendance) }
  let(:blueprint) { described_class.render(attendance) }

  it 'returns the correct fields' do
    expect(JSON.parse(blueprint).keys).to contain_exactly(
      'id',
      'absence',
      'check_in',
      'check_out',
      'child',
      'time_in_care',
      'child_approval_id'
    )
  end
end
