# frozen_string_literal: true

# spec/services/name_matching_actions_spec.rb

require 'rails_helper'

RSpec.describe NameMatchingActions, type: :service do
  subject(:actions) { described_class.new(matches: matches, file_child: file_child, business: business) }

  let(:file_child) { [Faker::Name.first_name, Faker::Name.last_name] }
  let(:business) { create(:business) }
  let(:matches) do
    [
      {
        'id' => Faker::Number.number(digits: 4),
        'first_name' => file_child[0] + Faker::Alphanumeric.alpha(number: 2),
        'last_name' => file_child[1] + Faker::Alphanumeric.alpha(number: 2),
        'sml_first_name' => Faker::Number.decimal(l_digits: 1, r_digits: 2).to_f,
        'sml_last_name' => Faker::Number.decimal(l_digits: 1, r_digits: 2).to_f
      }
    ]
  end

  describe '#call' do
    before do
      # rubocop:disable Rspec/SubjectStub
      allow(actions).to receive(:user_outputs).and_return(nil) # avoid actual console outputs
      # rubocop:enable Rspec/SubjectStub
    end

    it 'processes the matches' do
      expect(actions.call).to be_nil # Adjust as per the expected behavior
    end
  end

  describe '#match_tag' do
    context 'when score is zero' do
      it 'returns no_match' do
        expect(actions.send(:match_tag, 0)).to eq('no_match')
      end
    end

    context 'when score is positive but less than or equal to 0.99' do
      it 'returns close_match' do
        random_score = Faker::Number.between(from: 0.01, to: 0.99)
        expect(actions.send(:match_tag, random_score)).to eq('close_match')
      end
    end

    context 'when score is exactly 1' do
      it 'returns exact_match' do
        expect(actions.send(:match_tag, 1)).to eq('exact_match')
      end
    end
  end
end
