FactoryBot.define do
  factory :child_case_cycle_payment do
    amount { Faker::Number.between(from: 0, to: 999_999) }
    # Set a discrepancy value about 20% of the time:
    discrepancy { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Number.between(from: 0, to: amount) : nil }
    child_case_cycle
    payment
  end
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
#  slug                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  child_case_cycle_id  :uuid             not null
#  payment_id           :uuid             not null
#
# Indexes
#
#  index_child_case_cycle_payments_on_child_case_cycle_id  (child_case_cycle_id)
#  index_child_case_cycle_payments_on_payment_id           (payment_id)
#  index_child_case_cycle_payments_on_slug                 (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_case_cycle_id => child_case_cycles.id)
#  fk_rails_...  (payment_id => payments.id)
#
