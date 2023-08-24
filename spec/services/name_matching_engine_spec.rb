# frozen_string_literal: true

# spec/services/name_matching_engine_spec.rb

require 'rails_helper'

RSpec.describe NameMatchingEngine, type: :service do
  subject(:engine) { described_class.new(first_name: first_name, last_name: last_name) }

  let(:first_name) { 'John' }
  let(:last_name) { 'Doe' }

  describe '#call' do
    let(:mocked_result) do
      {
        'id' => 1,
        'first_name' => 'John',
        'last_name' => 'Doe',
        'sml_first_name' => 1,
        'sml_last_name' => 1
      }
    end

    before do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_return([mocked_result])
    end

    it 'returns the expected result' do
      result = engine.call
      expect(result[:match_tag]).to eq('exact_match')
      expect(result[:result_match]).to eq(mocked_result)
    end
  end

  describe '#match_tag' do
    context 'when score is zero' do
      it 'returns no_match' do
        expect(engine.match_tag(0)).to eq('no_match')
      end
    end

    context 'when score is positive but less than or equal to 0.99' do
      it 'returns close_match' do
        expect(engine.match_tag(0.5)).to eq('close_match')
      end
    end

    context 'when score is exactly 1' do
      it 'returns exact_match' do
        expect(engine.match_tag(1)).to eq('exact_match')
      end
    end
  end
end
