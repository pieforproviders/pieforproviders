# frozen_string_literal: true

# A temporary model to store dashboard data until we build calculations into the Nebraska Dashboard
class TemporaryNebraskaDashboardCase < UuidApplicationRecord
  belongs_to :child

  validates :absences, presence: true
  validates :attendance_risk, presence: true
  validates :earned_revenue, presence: true
  validates :estimated_revenue, presence: true
  validates :family_fee, presence: true
  validates :full_days, presence: true
  validates :hours, presence: true
  validates :hours_attended, presence: true
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
#  hours_attended    :string
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
