# frozen_string_literal: true

# This will enter all NE Hourly & Daily Rates for Family Child Care Home I & II as of 2021/08/13, subject to change
namespace :nebraska do
  desc 'Run all Nebraska rates'
  task rates: 'nebraska:all_rates'
end

namespace :nebraska do
  task all_rates: :environment do
    Rake::Task['nebraska:rates20210813'].invoke
  end
end
