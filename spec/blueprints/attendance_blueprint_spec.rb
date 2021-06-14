# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceBlueprint do
  let(:attendance) { create(:attendance) }
  let(:blueprint) { AttendanceBlueprint.render(attendance) }
  context 'returns the correct fields when no view option is passed' do
    it 'only includes the ID' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'id',
        'check_in',
        'check_out',
        'total_time_in_care',
        'child_approval_id'
      )
    end
  end
end
