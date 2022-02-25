# frozen_string_literal: true

# This is meant to simulate someone entering attendances during a month;
# it should work multiple times a month, and it should only generate
# attendances between the day it is run and the last attendance that was entered
desc 'Generate attendances this month'
task attendances: :environment do
  if Rails.application.config.allow_seeding
    DemoAttendanceSeeder.new.call
  else
    puts 'Error seeding attendances: this environment does not allow for seeding attendances'
  end
end
