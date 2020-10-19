# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillableOccurrenceRateType, type: :model do
  it { should belong_to(:billable_occurrence) }
  it { should belong_to(:rate_type) }
  it 'factory should be valid (default; no args)' do
    expect(build(:billable_occurrence_rate_type)).to be_valid
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
