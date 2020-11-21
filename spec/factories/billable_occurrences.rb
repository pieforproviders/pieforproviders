# frozen_string_literal: true

FactoryBot.define do
  factory :billable_occurrence do
    child_approval
    factory :billable_attendance do
      association :billable, factory: :attendance
    end
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
#  billable_id       :uuid
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
