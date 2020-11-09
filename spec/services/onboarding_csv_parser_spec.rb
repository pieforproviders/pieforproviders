# frozen_string_literal: true

require 'spec_helper'
require_relative File.join(__dir__, '..', '..', 'app','services','onboarding_csv_parser')

require 'json'

# For the MVP, we can assume that the CSV file is well formed: format is correct
#   and data is complete.
RSpec.describe OnboardingCsvParser do
  let(:headers) do
    %w[first_name
       last_name
       date_of_birth
       business_name
       business_zip_code
       business_county
       business_qris_rating
       case_number
       full_days
       part_days
       effective_on
       expires_on
       co_pay
       co_pay_frequency]
  end
  let(:header_row) { "#{headers.join(',')}\n" }

  let(:juan_ortiz_row) { 'Juan, Ortiz,2015-04-14, Happy Hearts Childcare,60606 , Cook,Gold, 1234567, 18,4,2019-11-12,2020-11-11,10000,Monthly' }
  let(:julia_ortiz_row) { 'Julia, Ortiz,2017-12-01, Happy Hearts Childcare,60606-3566, Cook,Gold, 1234567,22,5,2019-11-12,2020-11-11,10000,Monthly' }
  let(:amaury_mosi_row) { 'Amaury,Mòsi,2012-09-11,Goslings Grow,60688,Cook,Bronze,4567890,11,7,2020-02-04,2021-02-03,1200,Weekly' }

  let(:valid_1_row_csv) { header_row + juan_ortiz_row }
  let(:valid_3_rows_csv) { header_row + juan_ortiz_row + "\n" + julia_ortiz_row + "\n" + amaury_mosi_row }

  let(:csv_row_juan_ortiz) do
    CSV::Row.new(headers,
                 ['Juan',
                  'Ortiz',
                  Date.new(2015, 4, 14),
                  'Happy Hearts Childcare',
                  '60606',
                  'Cook',
                  'Gold',
                  '1234567',
                  18,
                  4,
                  Date.new(2019, 11, 12),
                  Date.new(2020, 11, 11),
                  10_000,
                  'Monthly'])
  end

  describe '.parse' do
    it 'is JSON of an empty array if the CSV is empty' do
      expect(described_class.parse('')).to eq([].to_json)
    end

    it 'creates a hash for each row' do
      expect(described_class).to receive(:create_all_strings_hash).exactly(3).times
                                                                  .and_return({}.to_json)
      described_class.parse(valid_3_rows_csv)
    end

    it 'json result is valid JSON and idempotent' do
      result = described_class.parse(valid_3_rows_csv)
      expect(JSON.parse(result).to_json).to eq result
    end
  end

  describe '.create_all_strings_hash' do
    it 'returns JSON for the row, keys = row headers, values = row values' do
      result = described_class.create_all_strings_hash(csv_row_juan_ortiz)
      expect(result.keys).to match_array(headers)
      expect(result['first_name']).to eq('Juan')
      expect(result['last_name']).to eq('Ortiz')
      expect(result['date_of_birth']).to eq('2015-04-14')
      expect(result['business_name']).to eq('Happy Hearts Childcare')
      expect(result['business_zip_code']).to eq('60606')
      expect(result['business_county']).to eq('Cook')
      expect(result['business_qris_rating']).to eq('Gold')
      expect(result['case_number']).to eq('1234567')
      expect(result['full_days']).to eq('18')
      expect(result['part_days']).to eq('4')
      expect(result['effective_on']).to eq('2019-11-12')
      expect(result['expires_on']).to eq('2020-11-11')
      expect(result['co_pay']).to eq('10000')
      expect(result['co_pay_frequency']).to eq('Monthly')
    end
  end
end
