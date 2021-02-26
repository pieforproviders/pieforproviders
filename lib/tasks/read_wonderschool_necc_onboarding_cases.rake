# frozen_string_literal: true

task read_wonderschool_necc_dashboard_cases: :environment do
  Wonderschool::Necc::OnboardingDownloader.new.call
end
