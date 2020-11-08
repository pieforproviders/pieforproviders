# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingCsvReader do
  describe '.import' do
    before(:each) do
      allow(described_class).to receive(:initial_counts)
      allow(described_class).to receive(:log_final_counts)
    end

    it 'gets the initial counts for classes to track' do
      allow(File).to receive(:open).and_return(true)

      expect(described_class).to receive(:initial_counts)
      Rails.logger.silence { described_class.import('faux.csv') }
    end

    it "default file name is Rails.root.join('onboarding_data.csv')" do
      allow(OnboardingCsvParser).to receive(:parse).and_return(true)

      expect(File).to receive(:open).with('faux.csv', 'r').and_return(true)
      Rails.logger.silence { described_class.import('faux.csv') }
    end

    it 'uses the filename provided' do
      allow(OnboardingCsvParser).to receive(:parse)

      given_filename = File.join(__dir__, 'blorfo.csv')
      expect(File).to receive(:open).with(given_filename, 'r')
                                    .and_return(true)
      Rails.logger.silence { described_class.import(given_filename) }
    end

    it 'reads the file and passes the contents to OnboardingCsvParserto parse and process' do
      expect(File).to receive(:open).with(file_fixture('onboarding_data.csv'), 'r').and_call_original
      expect(OnboardingCsvParser).to receive(:parse)
      Rails.logger.silence { described_class.import(file_fixture('onboarding_data.csv')) }
    end

    it 'logs the counts for classes after the file has been imported' do
      allow(File).to receive(:open).and_return(true)

      expect(described_class).to receive(:log_final_counts)
      Rails.logger.silence { described_class.import }
    end
  end

  describe '.initial_counts' do
    it 'converts the list of classes to a hash with the initial count of each class' do
      klass_a = double(Child)
      allow(klass_a).to receive(:count).and_return(5)
      expect(described_class.initial_counts([klass_a])).to eq({ klass_a => 5 })
    end
  end

  describe '.log_final_counts' do
    it 'logs the original and final counts for each item' do
      klass_a = double(Child)
      allow(klass_a).to receive(:count).and_return(5)
      allow(klass_a).to receive(:name).and_return('klass_a')
      klass_b = double(Approval)
      allow(klass_b).to receive(:count).and_return(5)
      allow(klass_b).to receive(:name).and_return('klass_b')

      expect(Rails.logger).to receive(:info).exactly(2).times
      counts_info = { klass_a => 3, klass_b => 3 }
      described_class.log_final_counts(counts_info)
    end
  end
end
