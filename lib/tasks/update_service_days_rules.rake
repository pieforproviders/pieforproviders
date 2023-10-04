# frozen_string_literal: true

namespace :db do
  desc 'Update service days with new Nebraska rules'
  task update_service_days_rules: :environment do
    start_date = Date.new(2023, 0o7, 0o1)
    outdated_service_days = ServiceDay.where('date > ?', start_date)
    state = State.find_by(name: 'Nebraska')

    outdated_service_days.each do |service_day|
      time_engine = TimeConversionEngine.new(service_day:, state:)
      update_params = time_engine.call
      service_day.update!(update_params)
      puts("Service Day: #{service_day.id} successfully updated")
    rescue StandardError => e
      puts("Error updating Service Day: #{service_day.id}. Error: #{e.message}")
    end
  end
end
