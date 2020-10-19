# frozen_string_literal: true

# Any item that can be billed to the state for subsidy pay
class BillableOccurrence < UuidApplicationRecord
  belongs_to :child_approval
  belongs_to :billable, polymorphic: true
  has_many :billable_occurrence_rate_types, dependent: :destroy
  has_many :rate_types, through: :billable_occurrence_rate_types
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
