# frozen_string_literal: true

task read_wonderschool_necc_onboarding_cases: :environment do
  Wonderschool::Necc::OnboardingDownloader.new.call
end
