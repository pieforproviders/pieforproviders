# frozen_string_literal: true

task read_wonderschool_necc_attendances: :environment do
  # Pull single file from Wonderschool URL
  # Process single file through Attendance Processor
  # Archive file to S3
  Wonderschool::Necc::AttendanceCsvImporter.new.call
  Appsignal.stop 'read_wonderschool_necc_attendances'
  sleep 5
end

task read_wonderschool_necc_dashboard_cases: :environment do
  # pull multiple files from S3
  # Process each file through Dashboard Processor
  # Archive each file to S3
  Wonderschool::Necc::DashboardCaseImporter.new.call
  Appsignal.stop 'read_wonderschool_necc_dashboard_cases'
  sleep 5
end

task read_wonderschool_necc_onboarding_cases: :environment do
  # pull multiple files from S3
  # Process each file through Onboarding Processor
  # Archive each file to S3
  Wonderschool::Necc::OnboardingCaseImporter.new.call
  Appsignal.stop 'read_wonderschool_necc_onboarding_cases'
  sleep 5
end
