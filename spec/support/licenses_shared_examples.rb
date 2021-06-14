# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'licenses' do
  let(:model) { described_class } # the class that includes the concern

  it 'validates the license type against the list' do
    license_object = FactoryBot.build(model.to_s.underscore.to_sym, license_type: 'family_in_home')
    expect(license_object).to be_valid
    license_object.license_type = 'fake license name'
    expect(license_object).not_to be_valid
  end
end
