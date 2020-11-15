# frozen_string_literal: true

require 'csv'
require_relative 'onboarding_csv_parser'

#--------------------------
#
# @class OnboardingCsvReader
#
# @desc Responsibility: Import Data in an Onboarding CSV file.  Create
#   objects as needed if they don't already exist.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/01/20
#
#--------------------------
#
class OnboardingCsvReader
  def self.import(full_filename)
    raise ArgumentError, 'Must provide a filename' if full_filename.blank?

    begin
      csv_file = File.open(full_filename, 'r')
      json = OnboardingCsvParser.parse(csv_file.read)
    ensure
      csv_file.close
    end

    json
  end
end
