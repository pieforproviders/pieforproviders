# frozen_string_literal: true

# On deployment to production, the dashboard
# needs to create absences in the past
# and create schedules for the children
desc 'Prep production kids for live algorithms'
task nebraska_dashboard_deploy: :environment do
  Child.nebraska.each do |child|
    today = Time.current.in_time_zone(child.timezone)
    # generate default schedules
    5.times do |idx|
      next if child.schedules.pluck(:weekday).include?(idx + 1)

      Schedule.create!(
        child: child,
        weekday: idx + 1,
        start_time: '9:00am',
        end_time: '5:00pm',
        effective_on: child.approvals.order(effective_on: :asc).first.effective_on
      )
    end
    # generate prior absences
    child.approvals.each do |approval|
      (approval.effective_on..([approval.expires_on, today].min)).each do |date|
        NebraskaAbsenceGenerator.new(child, date).call
      end
    end
  end
end
