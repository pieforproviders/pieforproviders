# frozen_string_literal: true

FactoryBot.define do
  factory :child_case_cycle do
    subsidy_rule
    child { association :child, business: create(:business, county: subsidy_rule.county) }
    case_cycle
    part_days_allowed { 1 }
    full_days_allowed { 1 }
  end
end

# == Schema Information
#
# Table name: child_case_cycles
#
#  id                :uuid             not null, primary key
#  full_days_allowed :integer          not null
#  part_days_allowed :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  case_cycle_id     :uuid             not null
#  child_id          :uuid             not null
#  subsidy_rule_id   :uuid             not null
#
# Indexes
#
#  index_child_case_cycles_on_case_cycle_id    (case_cycle_id)
#  index_child_case_cycles_on_child_id         (child_id)
#  index_child_case_cycles_on_subsidy_rule_id  (subsidy_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_cycle_id => case_cycles.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#
