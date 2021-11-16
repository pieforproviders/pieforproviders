# frozen_string_literal: true

# Check our kids' schedules every day and if there's no new attendance on a day they're scheduled,
# create an absence, up to 5 per month
# This will be put on Heroku Scheduler once a day
desc 'Create daily absences'
task nebraska_daily_absences: :environment do
  Child.nebraska.each do |child|
    Nebraska::AbsenceGenerator.new(child).call
  end
end
