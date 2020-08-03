# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { should belong_to(:site) }
  it { should belong_to(:agency) }

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
