# frozen_string_literal: true

# Agencies provide child care subsidy payments
class Agency < ApplicationRecord
  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true
end

# == Schema Information
#
# Table name: agencies
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  name       :string           not null
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
