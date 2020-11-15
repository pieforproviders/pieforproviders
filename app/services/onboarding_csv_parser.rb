# frozen_string_literal: true

require 'csv'

#--------------------------
#
# @class OnboardingCsvParser
#
# @desc Responsibility: Parse well-formed CSV IO with onboarding data and create a JSON String from it
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/01/20
#
#--------------------------
#
class OnboardingCsvParser
  DATE_FORMAT = '%m-%d-%Y'
  CONVERTERS = %i[numeric date].freeze

  # ----------------------------------------------------------------------

  def self.parse(data_string)
    csv_rows = CSV.parse(data_string,
                         headers: true,
                         return_headers: false,
                         unconverted_fields: %i[business_zip_code],
                         converters: CONVERTERS)
    rows = []
    csv_rows.each do |row|
      rows << create_all_strings_hash(row)
    end
    rows.to_json
  end

  # @return [Hash] - a Hash where all keys and values are Strings
  def self.create_all_strings_hash(row)
    row_h = row.to_h
    row_h.transform_keys! { |key| key.to_s.strip }
    row_h.transform_values! { |value| value.to_s.strip }
  end
end
