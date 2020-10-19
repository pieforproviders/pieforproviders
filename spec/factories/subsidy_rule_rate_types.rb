# frozen_string_literal: true

FactoryBot.define do
  factory :subsidy_rule_rate_type do
    subsidy_rule
    rate_type
  end
end

# == Schema Information
#
# Table name: subsidy_rule_rate_types
#
#  id              :uuid             not null, primary key
#  rate_type_id    :uuid             not null
#  subsidy_rule_id :uuid
#
# Indexes
#
#  index_subsidy_rule_rate_types_on_rate_type_id     (rate_type_id)
#  index_subsidy_rule_rate_types_on_subsidy_rule_id  (subsidy_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (rate_type_id => rate_types.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#
