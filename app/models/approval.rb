# frozen_string_literal: true

# An approval from the state to provide subsidy funding to a family's childcare provider(s)
class Approval < UuidApplicationRecord
  COPAY_FREQUENCIES = %w[daily weekly monthly].freeze

  has_many :child_approvals, dependent: :destroy
  has_many :children, through: :child_approvals
  has_many :illinois_approval_amounts, through: :child_approvals

  validates :effective_on, date_param: true
  validates :expires_on, date_param: true

  # need to do it this way because postgres/rails enums don't allow for nils
  # and there's a possibility we'll be handling approvals without copays, so
  # in order to preserve data integrity, I don't want to store false info
  enum copay_frequency: Copays.frequencies
  # validates :copay_frequency, inclusion: { in: COPAY_FREQUENCIES, allow_nil: true }

  scope :current, -> { where('effective_on <= ? AND expires_on > ?', Date.current, Date.current) }

  monetize :copay_cents, allow_nil: true
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :string
#  effective_on    :date
#  expires_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
