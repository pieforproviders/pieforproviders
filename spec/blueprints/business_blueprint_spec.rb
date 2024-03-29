# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessBlueprint do
  let(:business) { create(:business) }
  let(:blueprint) { described_class.render(business) }

  it 'only includes the expected fields' do
    expect(JSON.parse(blueprint).keys).to contain_exactly('id', 'name')
  end

  context 'when IL view is requested' do
    let(:blueprint) { described_class.render(business, view: :illinois_dashboard) }

    it 'includes the business name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'cases',
        'name'
      )
    end
  end

  context 'when NE view is requested' do
    let(:blueprint) { described_class.render(business, view: :nebraska_dashboard) }

    it 'includes the business name and all cases' do
      expect(JSON.parse(blueprint).keys).to contain_exactly(
        'cases',
        'name',
        'id'
      )
    end
  end
end
