# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class NebraskaDashboardCase < UuidApplicationRecord
  belongs_to :child

  scope :for_date,
        lambda { |date = nil, timezone = nil|
          date ||= Time.current
          where(month: date.in_time_zone(timezone).at_beginning_of_month)
        }
end

# == Schema Information
#
# Table name: nebraska_dashboard_cases
#
#  id                         :uuid             not null, primary key
#  absences                   :integer          default(0), not null
#  attendance_risk            :string           default("not_enough_info"), not null
#  attended_weekly_hours      :float            default(0.0), not null
#  earned_revenue_cents       :integer
#  earned_revenue_currency    :string           default("USD"), not null
#  estimated_revenue_cents    :integer
#  estimated_revenue_currency :string           default("USD"), not null
#  full_days                  :integer          default(0), not null
#  full_days_remaining        :integer          default(0), not null
#  hours                      :float            default(0.0), not null
#  hours_remaining            :float            default(0.0), not null
#  month                      :datetime         default(Wed, 11 May 2022 18:39:32.629540000 UTC +00:00), not null
#  scheduled_revenue_cents    :integer
#  scheduled_revenue_currency :string           default("USD"), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  child_id                   :uuid             not null
#
# Indexes
#
#  index_nebraska_dashboard_cases_on_child_id            (child_id)
#  index_nebraska_dashboard_cases_on_month_and_child_id  (month,child_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
