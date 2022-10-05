# frozen_string_literal: true

# This will read from illinois_rates0701.csv file to import IllinoisRates for 2022-07-01
desc 'Import all Illinois Rates effective on 2022-07-01'
namespace :illinois do
  task illinois_rates0916: :environment do
    table = CsvParser.new(File.read('lib/tasks/illinois/illinois_rates0701.csv')).call
    table.each do |row|
      IllinoisRate.find_or_create_by!(
        region: row['Geography'].downcase.tr(' ', '_'),
        effective_on: row['Effective on (date)'],
        amount: row['Amount']&.to_s&.gsub(/[^\d.]/, '')&.to_f,
        license_type: row['License Type'].downcase.tr(' -', '_'),
        age_bucket: row['Max age']&.to_f,
        rate_type: row['Time Unit'].downcase.tr(' ', '_'),
        name: row['ID']
      )
    end
  end
end
