# frozen_string_literal: true

# Remove absences marked on a not attending period
task remove_not_attending_absences: :environment do
  children = Child.joins(:not_attending_period)
  absences = []
  children.each do |child|
    start_date = child.not_attending_period.start_date
    end_date = child.not_attending_period.end_date
    absences += child.service_days.where('date between ? and ?', start_date, end_date)
                     .where(absence_type: 'absence_on_scheduled_day')
  end

  absences.each(&:destroy)

  puts "Successfully removed #{absences.count} absences."
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
