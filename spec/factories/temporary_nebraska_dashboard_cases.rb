# frozen_string_literal: true

FactoryBot.define do
  factory :temporary_nebraska_dashboard_case do
    child
    absences { '2 of 10' }
    attendance_risk { 'on_track' }
    earned_revenue { '1234.05' }
    estimated_revenue { '3562.89' }
    full_days { '10 of 12' }
    hours { '2 of 2' }
    transportation_revenue { '28 trips - $380.14' }
  end
end
