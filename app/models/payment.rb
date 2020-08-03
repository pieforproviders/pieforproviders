# frozen_string_literal: true

# Payments made by an agency to a provide for a particular site
class Payment < ApplicationRecord
  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  belongs_to :agency
  belongs_to :site

  # TODO what is the right way to construct the slug?  What if 2 (partial) payments are made on the same day for the same [care period + site] from an agency?
  before_validation { |payment| payment.slug = generate_slug("#{payment.care_started_on}#{payment.site_id}#{payment.agency_id}") }
end

# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount_cents         :integer          default(0), not null
#  amount_currency      :string           default("USD"), not null
#  care_finished_on     :date
#  care_started_on      :date
#  discrepancy_cents    :integer          default(0), not null
#  discrepancy_currency :string           default("USD"), not null
#  paid_on              :date
#  slug                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  agency_id            :uuid             not null
#  site_id              :uuid             not null
#
# Indexes
#
#  index_payments_on_site_id                (site_id)
#  index_payments_on_site_id_and_agency_id  (site_id,agency_id)
#
