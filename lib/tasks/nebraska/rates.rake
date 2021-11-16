# frozen_string_literal: true

# This will enter all NE Hourly & Daily Rates for Family Child Care Home I & II as of 2021/08/13, subject to change
namespace :nebraska do
  desc 'Run all Nebraska rates'
  task rates: 'nebraska:all_rates'
end

namespace :nebraska do
  task all_rates: :environment do
    if Rails.application.config.allow_seeding
      Rake::Task['nebraska:rates20210813'].invoke
      Rake::Task['nebraska:rates20210924'].invoke
    else
      puts 'Error seeding rates: this environment does not allow for seeding rates'
    end
  end
end
