# frozen_string_literal: true

task read_wonderschool_necc_attendances: :environment do
  Wonderschool::Necc::AttendanceCsvImporter.new.call
end

task read_wonderschool_necc_dashboard_cases: :environment do
  Wonderschool::Necc::DashboardCsvImporter.new.call
end

task read_wonderschool_necc_onboarding_cases: :environment do
  Wonderschool::Necc::OnboardingCsvImporter.new.call
end
