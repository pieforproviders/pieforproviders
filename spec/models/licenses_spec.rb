# frozen_string_literal: true

require 'spec_helper'
require_relative File.join(__dir__, '..', '..', 'app', 'models', 'licenses')

RSpec.describe Licenses do
  it '.types' do
    expected_values = %w[licensed_center
                         licensed_family_home
                         licensed_group_home
                         license_exempt_home
                         license_exempt_center].freeze
    expect(described_class.types).to match(expected_values.to_h { |value| [value.to_sym, value] })
  end
end
