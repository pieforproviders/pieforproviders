# frozen_string_literal: true

FactoryBot.define do
  factory :billable_occurrence_rate_type do
    billable_occurrence
    rate_type
  end
end

# == Schema Information
#
# Table name: billable_occurrence_rate_types
#
#  id                     :uuid             not null, primary key
#  billable_occurrence_id :uuid
#  rate_type_id           :uuid             not null
#
# Indexes
#
#  index_billable_occurrence_rate_types_on_billable_occurrence_id  (billable_occurrence_id)
#  index_billable_occurrence_rate_types_on_rate_type_id            (rate_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (billable_occurrence_id => billable_occurrences.id)
#  fk_rails_...  (rate_type_id => rate_types.id)
#
