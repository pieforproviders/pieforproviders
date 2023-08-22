# frozen_string_literal: true

desc 'Load holidays'
task load_holidays: :environment do
  # pull multiple files from S3
  # Process each file through Holidays Processor
  # Archive each file to S3
  HolidaysImporter.new.call
  Appsignal.stop 'load_holidays'
  sleep 5
end
