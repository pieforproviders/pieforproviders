# frozen_string_literal: true

# The portion of a payment for a specific child's case (ChildCaseCycle).
class ChildCaseCyclePayment < UuidApplicationRecord
  belongs_to :child_case_cycle
  belongs_to :payment

  monetize :amount_cents
  monetize :discrepancy_cents, allow_nil: true

  validates :amount, numericality: { greater_than: 0 }
end

# == Schema Information
#
# Table name: child_case_cycle_payments
#
#  id                   :uuid             not null, primary key
#  amount_cents         :integer          default(0), not null
#  amount_currency      :string           default("USD"), not null
#  discrepancy_cents    :integer
#  discrepancy_currency :string           default("USD")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  child_case_cycle_id  :uuid             not null
#  payment_id           :uuid             not null
#
# Indexes
#
#  index_child_case_cycle_payments_on_child_case_cycle_id  (child_case_cycle_id)
#  index_child_case_cycle_payments_on_payment_id           (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_case_cycle_id => child_case_cycles.id)
#  fk_rails_...  (payment_id => payments.id)
#
