# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    child_case_cycle
    starts_on { Date.current }
    length_of_care { Attendance::LENGTHS_OF_CARE.sample }
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                  :uuid             not null, primary key
#  length_of_care      :enum             default("full_day"), not null
#  slug                :string           not null
#  starts_on           :date             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  child_case_cycle_id :uuid             not null
#
# Indexes
#
#  index_attendances_on_child_case_cycle_id  (child_case_cycle_id)
#  index_attendances_on_slug                 (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_case_cycle_id => child_case_cycles.id)
#
