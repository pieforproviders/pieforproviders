# frozen_string_literal: true

# This is meant to simulate someone entering dashboard data on any
# given day of the month; it should work multiple times a month
desc 'Generate attendances this month'
task temporary_ne_dash: :environment do
  if ENV.fetch('ALLOW_SEEDING', 'false') == 'true'
    generate_dashboard
  else
    puts 'Error seeding dashboard: this environment does not allow for seeding dashboard'
  end
end

def generate_dashboard
  Child.includes(:business).where(business: { state: 'NE' }).each do |child|
    total_absences = rand(0..10).round
    total_days = rand(0..25).round
    total_hours = rand(0.0..10.0).round

    TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child).update!(
      attendance_risk: %w[on_track exceeded_limit ahead_of_schedule at_risk].sample,
      absences: "#{rand(0..total_absences)} of #{total_absences}",
      earned_revenue: rand(0.00..1000.00).round(2),
      estimated_revenue: rand(1000.00..2000.00).round(2),
      full_days: "#{rand(0..total_days)} of #{total_days}",
      hours: "#{rand(0.0..total_hours).round(2)} of #{total_hours}",
      transportation_revenue: "#{rand(0..30)} trips - #{Money.new(rand(0..100_000)).format}"
    )
  end
end
