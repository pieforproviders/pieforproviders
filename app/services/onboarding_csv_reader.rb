# frozen_string_literal: true

require 'csv'

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
  IMPORT_FN = Rails.root.join('onboarding_data.csv')

  def self.import(full_filename = IMPORT_FN)
    classes_to_count = [Child, ChildApproval]
    orig_counts = initial_counts(classes_to_count)

    Rails.logger.info ">>> Importing #{full_filename}..."

    File.open(full_filename, 'r') do |csv_file|
      OnboardingCsvParser.parse(csv_file.read)
    end

    Rails.logger.info "  Finished importing #{full_filename}"
    log_final_counts(orig_counts)
  end

  def self.initial_counts(classes_tracked = [])
    classes_tracked.index_with { |klass| klass.send(:count) }
  end

  def self.log_final_counts(orig_counts = {})
    orig_counts.each do |klass, orig_count|
      Rails.logger.info "   #{klass.send(:count) - orig_count} total #{klass.name} added"
    end
  end
end
