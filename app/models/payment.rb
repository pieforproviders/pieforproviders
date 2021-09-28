# frozen_string_literal: true

# An individual payment for a child
class Payment < UuidApplicationRecord
  belongs_to :child_approval

  validates :amount, numericality: { greater_than_or_equal_to: 0.00 }, presence: true
  validates :month, presence: true
end

# == Schema Information
#
# Table name: payments
#
#  id                        :uuid             not null, primary key
#  month                     :date             not null
#  amount                    :decimal(, )      not null
#  child_approval_id         :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
