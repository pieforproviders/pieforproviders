# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { should belong_to(:site) }
  it { should belong_to(:agency) }
  it { should validate_numericality_of(:amount).is_greater_than(0.00) }
  it { should validate_presence_of(:care_finished_on) }
  it { should validate_presence_of(:care_started_on) }
  it { should validate_numericality_of(:discrepancy) }
  it { should validate_presence_of(:paid_on) }
  it { is_expected.to monetize(:amount) }
  it { is_expected.to monetize(:discrepancy) }
end

# == Schema Information
#
# Table name: payments
#
#  id                :uuid             not null, primary key
#  amount_cents      :integer          default(0), not null
#  care_finished_on  :date             not null
#  care_started_on   :date             not null
#  discrepancy_cents :integer          default(0), not null
#  paid_on           :date             not null
#  slug              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  agency_id         :uuid             not null
#  site_id           :uuid             not null
#
# Indexes
#
#  index_payments_on_site_id                (site_id)
#  index_payments_on_site_id_and_agency_id  (site_id,agency_id)
#
