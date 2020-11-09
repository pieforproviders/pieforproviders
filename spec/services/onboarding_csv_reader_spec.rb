# frozen_string_literal: true

require 'spec_helper'
require_relative File.join(__dir__, '..', '..', 'app', 'services', 'onboarding_csv_reader')
require_relative File.join(__dir__, '..', '..', 'app', 'services', 'onboarding_csv_parser')

require 'json'

RSpec.describe OnboardingCsvReader do

  test_csv_fn = File.join(__dir__, '..', 'fixtures', 'files', 'onboarding_data.csv')

  describe '.import' do

    it "raises an error if no filename is provided" do
      expect { described_class.import(nil) }.to raise_error ArgumentError
      expect { described_class.import('') }.to raise_error ArgumentError
    end

    it 'uses the filename provided' do
      allow(OnboardingCsvParser).to receive(:parse)

      given_filename = File.join(__dir__, 'blorfo.csv')
      expect(File).to receive(:open).with(given_filename, 'r')
                                    .and_return(true)
      described_class.import(given_filename)
    end

    it 'reads the file and passes the contents to OnboardingCsvParser to parse and process' do
      expect(File).to receive(:open).with(test_csv_fn, 'r').and_call_original
      expect(OnboardingCsvParser).to receive(:parse).and_return('{}')
      described_class.import(test_csv_fn)
    end

    it 'json result is valid JSON and idempotent' do
      result = described_class.import(test_csv_fn)
      expect(JSON.parse(result).to_json).to eq result
    end
  end
end
