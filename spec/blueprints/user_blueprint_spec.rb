# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlueprint do
  let(:user) { create(:user) }
  let(:blueprint) { UserBlueprint.render(user) }
  context 'returns the correct fields when no view option is passed' do
    it 'only includes the ID' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'greeting_name',
        'id',
        'language',
        'state'
      )
    end
  end
  context 'returns the correct fields when IL view is requested' do
    let(:blueprint) { UserBlueprint.render(user, view: :illinois_dashboard) }
    it 'includes IL dashboard fields' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'as_of',
        'businesses',
        'first_approval_effective_date'
      )
    end
  end
  context 'returns the correct fields when NE view is requested' do
    let(:blueprint) { UserBlueprint.render(user, view: :nebraska_dashboard) }
    it 'includes the user name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'as_of',
        'first_approval_effective_date',
        'businesses',
        'max_revenue',
        'total_approved'
      )
    end
  end
end
