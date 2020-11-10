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

    json = String.new  # TODO: rubocop flags this, but I don't know how else to initialize it.
    File.open(full_filename, 'r') do |csv_file|
      json << OnboardingCsvParser.parse(csv_file.read)
    end
    json
  end
end
