# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessBlueprint do
  let(:business) { create(:business) }
  let(:blueprint) { BusinessBlueprint.render(business) }

  context 'returns the correct fields when no view option is passed' do
    it 'only includes the ID' do
      expect(JSON.parse(blueprint).keys).to contain_exactly('id')
    end
  end

  context 'returns the correct fields when IL view is requested' do
    let(:blueprint) { BusinessBlueprint.render(business, view: :illinois_dashboard) }

    it 'includes the business name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'cases',
        'name'
      )
    end
  end

  context 'returns the correct fields when NE view is requested' do
    let(:blueprint) { BusinessBlueprint.render(business, view: :nebraska_dashboard) }

    it 'includes the business name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'cases',
        'name'
      )
    end
  end
end
