# frozen_string_literal: true

require 'csv'

# Parses CSVs using options defined in the private methods
class CsvParser
  include AppsignalReporting

  def initialize(contents)
    @contents = contents
  end

  def call
    parse_csv
  end

  private

  def parse_csv
    CSV.parse(@contents, **csv_options)
  rescue StandardError => e
    send_appsignal_error('csv-parser', e.message)
  end

  def csv_options
    {
      headers: true,
      liberal_parsing: true,
      return_headers: false,
      skip_lines: /^(,*|\s*)$/,
      unconverted_fields: %i[child_id],
      converters: %i[date],
      skip_blanks: true
    }
  end
end
