# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildBlueprint do
  let(:child) { create(:child) }
  let(:blueprint) { ChildBlueprint.render(child) }
  context 'returns the correct fields when no view option is passed' do
    it 'only includes the ID' do
      expect(JSON.parse(blueprint).keys).to contain_exactly('id')
    end
  end
  context 'returns the correct fields when IL view is requested' do
    let(:blueprint) { ChildBlueprint.render(child, view: :illinois_dashboard) }
    it 'includes IL dashboard fields' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'id',
        'attendance_rate',
        'attendance_risk',
        'case_number',
        'full_name',
        'guaranteed_revenue',
        'max_approved_revenue',
        'potential_revenue'
      )
    end
  end
  context 'returns the correct fields when NE view is requested' do
    let(:blueprint) { ChildBlueprint.render(child, view: :nebraska_dashboard) }
    it 'includes the child name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'id',
        'absences',
        'attendance_risk',
        'case_number',
        'earned_revenue',
        'estimated_revenue',
        'family_fee',
        'full_days',
        'full_name',
        'hours',
        'hours_attended'
      )
    end
  end
end
