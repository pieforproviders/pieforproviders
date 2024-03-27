# frozen_string_literal: true

# spec/services/name_matching_engine_spec.rb

require 'rails_helper'

RSpec.describe NameMatchingEngine, type: :service do
  subject(:engine) { described_class.new(first_name:, last_name:) }

  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  describe '#call' do
    let(:mocked_result) do
      {
        'id' => Faker::Number.number(digits: 4),
        'first_name' => first_name + Faker::Alphanumeric.alpha(number: 2),
        'last_name' => last_name + Faker::Alphanumeric.alpha(number: 2),
        'sml_first_name' => Faker::Number.decimal(l_digits: 0, r_digits: 2).to_f,
        'sml_last_name' => Faker::Number.decimal(l_digits: 0, r_digits: 2).to_f
      }
    end

    before do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_return([mocked_result])
    end

    it 'returns the expected result' do
      result = engine.call
      expected_match_tag = engine.match_tag((mocked_result['sml_first_name'] + mocked_result['sml_last_name']) / 2)
      expect(result.first[:match_tag]).to eq(expected_match_tag)
      expect(result.first[:first_name]).to eq(mocked_result['first_name'])
      expect(result.first[:last_name]).to eq(mocked_result['last_name'])
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
        random_score = Faker::Number.between(from: 0.01, to: 0.99)
        expect(engine.match_tag(random_score)).to eq('close_match')
      end
    end

    context 'when score is exactly 1' do
      it 'returns exact_match' do
        expect(engine.match_tag(1)).to eq('exact_match')
      end
    end
  end
end
