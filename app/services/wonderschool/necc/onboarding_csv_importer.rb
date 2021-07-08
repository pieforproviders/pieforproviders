# frozen_string_literal: true

module Wonderschool
  module Necc
    # Wonderschool NECC Onboarding CSV Importer
    class OnboardingCsvImporter < S3CsvImporter
      private
      def source_bucket
        Rails.application.config.aws_necc_onboarding_bucket
      end

      def process_file(csv)
        csv.each do |row|
          create_case(row)
        end
      end

      def create_case(row)
        # find or create business
        # find or create approval
        # create child
        # create child_approval
        # create nebraska_approval_amounts
      end
    end
  end
end