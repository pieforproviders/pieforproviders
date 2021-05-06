# frozen_string_literal: true

require 'csv'

# Service to import rules from a csv file. Currently pulls file from command line arg. TODO: use S3
class NebraskaRatesImporter

  def initialize(file_name)
    @file_name = file_name
    @headers = %w[
      state
      county
      age
      license_type
      rate_type
      qris_enhancement_threshold
      special_needs_enhancement_threshold
      accreditation_enhancement_threshold
      effective_on
      expires_on
    ]
  end

  def call
    import_rates_from_csv
  end

  private

  def import_rates_from_csv
    contents = process_file
    if contents && write_all(contents)
      log('info', "import succeeded: #{@file_name}")
    else
      log('error', "import failed: #{@file_name}")
    end
  end

  def process_file
    rates_file = read_csv_file
    if (contents = parse_csv(rates_file))
      log('info', "found: #{@file_name}. Importing...\n #{contents}")
    else
      log('error', "parse failed: #{@file_name}")
      return
    end
    contents
  end

  def read_csv_file
    log('error', "file not found: #{@file_name}") and return false if @file_name.is_a?(Pathname) && !File.exist?(@file_name)

    File.read(@file_name)
  end

  def parse_csv(rates_file)
    contents_table = CSV.parse(
      rates_file,
      headers: true,
      return_headers: false,
      skip_lines: /^(,*|\s*)$/
    )
    contents_table.headers.each_with_index do |file_header, i|
      log('error', "unexpected file header. expected #{@headers} found #{contents_table.headers}") and return false if file_header.casecmp(@headers[i]).nonzero?
    end

    contents_table
  end

  def write_all(contents_table)
    ActiveRecord::Base.transaction do
      contents_table.each do |entry|
        if entry['state'] != 'NE'
          log('error', "data import for states other than Nebraska not supported. found #{entry['state']}")
          return false
        end

        insert_entry(entry)
      end
    end
    true
  end

  def insert_entry(csv_entry)
    record_entry = to_record_entry(csv_entry)
    NebraskaRate.find_or_create_by!(record_entry)
    log('info', "wrote: #{record_entry}")
  rescue ActiveRecord::RecordInvalid => e
    log('error', e.to_s)
    false
  end

  def to_record_entry(csv_entry)
    log('info', "gonna convert: #{csv_entry}")
    record_entry = csv_entry.to_hash
    record_entry["max_age"] = record_entry["age"]
    record_entry.delete("state")
    record_entry.delete("age")
    log('info', "gonna write: #{record_entry}")
    record_entry
  end

  def log(level, message)
    Rails.logger.tagged('Nebraska rates importer') { Rails.logger.method(level).call message }
  end
end
