# frozen_string_literal: true

# This fixes missing absences from a bug in our daily job
desc 'update all SchoolAge and School_Age rates to include a school_age parameter'
task fix_school_age_rates: :environment do
  NebraskaRate.where('name like ?', '%School_Age%').each do |rate|
    rate.update!(school_age: true)
  end
end
