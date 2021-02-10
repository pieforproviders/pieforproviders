# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TemporaryNebraskaDashboardCase, type: :model do
  it { should belong_to(:child) }

  let(:temporary_nebraska_dashboard_case) { build(:temporary_nebraska_dashboard_case) }

  it 'factory should be valid (default; no args)' do
    expect(build(:temporary_nebraska_dashboard_case)).to be_valid
  end
end
