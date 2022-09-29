# frozen_string_literal: true

# This will update the expiration date for all nebraska rates effective on 7-1-2021
desc 'Update expiration date for all nebraska rates effective on 7-1-2021 and recalculate service days'
task update_rate_expiry_date2021: :environment do
  NebraskaRate.where(effective_on: '2021-07-01').each do |rate|
    rate.update!(expires_on: '2022-06-30'.to_date.end_of_day)
  end

  ServiceDay.where(date: ('2022-07-01'.to_date)..Time.current.at_end_of_day).each do |service_day|
    ServiceDayCalculator.new(service_day: service_day).call
  end
end
