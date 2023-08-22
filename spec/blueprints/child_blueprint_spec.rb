# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildBlueprint do
  let(:child) { create(:child) }
  let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }

  it 'includes the ID, full name, and active info' do
    expect(JSON.parse(described_class.render(child)).keys).to contain_exactly(
      'id',
      'active',
      'first_name',
      'last_name',
      'last_active_date',
      'last_inactive_date',
      'inactive_reason',
      'wonderschool_id',
      'business_name'
    )
  end

  context 'when IL view is requested' do
    it 'includes IL dashboard fields' do
      expect(JSON.parse(described_class.render(child, view: :illinois_dashboard)).keys).to contain_exactly(
        'active',
        'business_name',
        'first_name',
        'id',
        'illinois_dashboard_case',
        'inactive_reason',
        'last_active_date',
        'last_inactive_date',
        'last_name',
        'wonderschool_id'
      )
    end
  end

  context 'when NE view is requested' do
    let(:child) { create(:necc_child) }

    it 'includes NE dashboard fields' do
      expect(JSON.parse(described_class.render(child, view: :nebraska_dashboard)).keys).to contain_exactly(
        'id',
        'active',
        'first_name',
        'last_name',
        'last_active_date',
        'last_inactive_date',
        'inactive_reason',
        'nebraska_dashboard_case',
        'wonderschool_id',
        'business_name'
      )
    end
  end
end
