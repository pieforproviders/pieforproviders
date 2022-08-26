# frozen_string_literal: true

desc 'Onboard illinois cases'
task read_illinois_onboarding_cases: :environment do
  # pull multiple files from S3
  # Process each file through Onboarding Processor
  # Archive each file to S3
  IllinoisOnboardingCaseImporter.new.call
  Appsignal.stop 'read_wonderschool_necc_onboarding_cases'
  sleep 5
end
