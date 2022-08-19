# frozen_string_literal: true

# This fixes the mixxing school age param from recent nebraska rates and recalculates
desc 'update all SchoolAge and School_Age rates to include a school_age parameter'
task fix_school_age_rates: :environment do
  NebraskaRate.where('name like ?', '%School_Age%').each do |rate|
    rate.update!(school_age: true)
  end
  ServiceDay.where(date: ('2022-07-01'.to_date)..Time.current.at_end_of_day).each do |service_day|
    ServiceDayCalculatorJob.perform_later(service_day)
  end
end
