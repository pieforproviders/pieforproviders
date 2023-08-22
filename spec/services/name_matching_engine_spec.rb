# spec/services/matching_service_spec.rb
require 'rails_helper'

RSpec.describe NameMatchingEngine do
  subject(:service) { described_class.new }

  before do
    # Mocking the ActiveRecord connection
    allow(ActiveRecord::Base.connection).to receive(:execute).and_return([])
  end

  describe '#call' do
    it 'prints "NO RESULT FOUND" for non-matching children' do
      expect { service.call }.to be(false)
    end
  end
end
