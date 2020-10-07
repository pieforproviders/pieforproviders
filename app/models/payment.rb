# frozen_string_literal: true

# Payments made by an agency to a provide for a particular site.
#   One payment from an agency might apply to several children's cases
#   (ChildCaseCycles).
class Payment < UuidApplicationRecord
  belongs_to :agency

  validates :amount, numericality: { greater_than: 0.00 }
  validates :care_finished_on, date_param: true
  validates :care_started_on, date_param: true
  validates :paid_on, date_param: true

  # The money-rails gem specifically requires that the '_cents' suffix be
  # specified when using the "monetize" macro even though the attributes are
  # referred to without the '_cents' suffix.
  # IOW, you only need to refer to payment.amount or payment.discrepancy ,
  # unlike the following statements.
  monetize :amount_cents
  monetize :discrepancy_cents, allow_nil: true
end

# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount_cents         :integer          default(0), not null
#  amount_currency      :string           default("USD"), not null
#  care_finished_on     :date             not null
#  care_started_on      :date             not null
#  discrepancy_cents    :integer
#  discrepancy_currency :string           default("USD")
#  paid_on              :date             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  agency_id            :uuid             not null
#
