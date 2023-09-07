# frozen_string_literal: true

namespace :pie_demo do
  desc 'Load and create fake businesses users accounts'
  task load_fake_businesses_for_demo: :environment do
    table = CsvParser.new(File.read('lib/tasks/users-demo-memory-leak.csv')).call
    table.each do |row|
      user = User.where(email: row['email']).first_or_create(
        active: true,
        full_name: row['full_name'],
        language: 'en',
        opt_in_email: true,
        opt_in_text: true,
        phone_number: row['phonenumber'],
        state: row['state'],
        get_from_pie: 'fame',
        organization: row['full_name'],
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
