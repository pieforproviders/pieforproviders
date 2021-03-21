# frozen_string_literal: true

FactoryBot.define do
  factory :temporary_nebraska_dashboard_case do
    child
    absences { '2 of 10' }
    attendance_risk { 'on_track' }
    earned_revenue { '1234.05' }
    estimated_revenue { '3562.89' }
    family_fee { 120.00 }
    full_days { '10 of 12' }
    hours { '2 of 2' }
  end
end

# == Schema Information
#
# Table name: temporary_nebraska_dashboard_cases
#
#  id                :uuid             not null, primary key
#  absences          :text
#  as_of             :string
#  attendance_risk   :text
#  earned_revenue    :text
#  estimated_revenue :text
#  family_fee        :decimal(, )
#  full_days         :text
#  hours             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  child_id          :uuid             not null
#
# Indexes
#
#  index_temporary_nebraska_dashboard_cases_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
