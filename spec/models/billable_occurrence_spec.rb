# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillableOccurrence, type: :model do
  it { should belong_to(:child_approval) }
  it 'factory should be valid (default; no args)' do
    expect(build(:billable_attendance)).to be_valid
  end
end

# == Schema Information
#
# Table name: billable_occurrences
#
#  id                :uuid             not null, primary key
#  billable_type     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  billable_id       :bigint
#  child_approval_id :uuid             not null
#
# Indexes
#
#  billable_index                                   (billable_type,billable_id)
#  index_billable_occurrences_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
