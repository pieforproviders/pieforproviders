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

namespace :illinois do

  desc 'Load and create fake businesses users accounts'
  task load_fake_businesses_users: :environment do
    table = CsvParser.new(File.read('lib/tasks/illinois/fake_businesses.csv')).call
    table.each_with_index do |row, index|
      user = User.where(email: row["Provider Email"]).first_or_create(
        active: true,
        full_name: row["Provider Name"],
        language: 'en',
        opt_in_email: true,
        opt_in_text: true,
        phone_number: "777-666-333#{index}",
        state: 'IL',
        get_from_pie: 'fame',
        organization: row["Provider Name"],
        password: 'testpass1234!',
        password_confirmation: 'testpass1234!',
        service_agreement_accepted: true,
        timezone: 'Eastern Time (US & Canada)',
        stressed_about_billing: 'True',
        accept_more_subsidy_families: 'True',
        not_as_much_money: 'True',
        too_much_time: 'True'
      )
      user.confirm
    end
  end
end