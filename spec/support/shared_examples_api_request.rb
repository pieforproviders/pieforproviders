# frozen_string_literal: true

require 'rails_helper'

VALID_API_PATH = '/api/v1'

# TODO: reintegrate these examples in the specs
# ------------------------------------------------------------------------------
# Examples that test for common error conditions:

# TODO: implement these without rswag dsl
# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
RSpec.shared_context 'with wrong api version with parameters' do |record_name|
  include_context 'with incorrect api version header'
  context 'when authenticated' do
    include_context 'when authenticated'
    response '500', 'internal server error' do
      let(record_name.to_sym) { { record_name => record_params } }
      run_test!
    end
  end

  context 'when not authenticated' do
    response '500', 'internal server error' do
      let(record_name.to_sym) { { record_name => record_params } }
      run_test!
    end
  end
end

RSpec.shared_context 'with wrong api version' do
  include_context 'with incorrect api version header'
  context 'when authenticated' do
    include_context 'when authenticated'
    response '500', 'internal server error' do
      run_test!
    end
  end

  context 'when not authenticated' do
    response '500', 'internal server error' do
      run_test!
    end
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
RSpec.shared_context 'when not authenticated with parameters' do |record_name|
  response '401', 'not authorized' do
    let(record_name.to_sym) { { record_name => record_params } }
    run_test!
  end
end

RSpec.shared_examples 'when not authenticated' do
  response '401', 'not authorized' do
    run_test!
  end
end

# This example expects the following to be defined with a let(:) block:
#  record_params - parameters to be passed to the server
RSpec.shared_context 'when not found with parameters' do |record_name|
  response '404', "#{record_name} not found" do
    let(:id) { 'invalid' }
    let(record_name.to_sym) { { record_name => record_params } }
    run_test!
  end
end

RSpec.shared_context 'when not found' do |record_name|
  response '404', "#{record_name} not found" do
    let(:id) { 'invalid' }
    run_test!
  end
end

# ------------------------------------------------------------------------------
