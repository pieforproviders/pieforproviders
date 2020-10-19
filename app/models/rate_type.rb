# frozen_string_literal: true

# Rate types that may be applied for care
class RateType < UuidApplicationRecord
  has_many :subsidy_rule_rate_types, dependent: :restrict_with_error
  has_many :subsidy_rules, through: :subsidy_rule_rate_types
  has_many :child_approval_rate_types, dependent: :restrict_with_error
  has_many :child_approvals, through: :child_approval_rate_types
  has_many :billable_occurrence_rate_types, dependent: :restrict_with_error
  has_many :billable_occurrences, through: :billable_occurrence_rate_types

  validates :name, presence: true

  monetize :amount_cents
end

# == Schema Information
#
# Table name: rate_types
#
#  id              :uuid             not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  max_duration    :decimal(, )
#  name            :string           not null
#  threshold       :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
