# frozen_string_literal: true

require 'spec_helper'
require_relative File.join(__dir__, '..', '..', 'app', 'models', 'license_types')

RSpec.describe LicenseTypes do
  it '.valid_types' do
    expected_values = %w[licensed_center
                         licensed_family_home
                         licensed_group_home
                         license_exempt_home
                         license_exempt_center].freeze
    expect(described_class.valid_types).to match(expected_values.to_h { |value| [value.to_sym, value] })
  end
end
