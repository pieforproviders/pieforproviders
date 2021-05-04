# frozen_string_literal: true

# Subsidy rules - polymorphic "parent" class
# These records will be manually added to the db either through rake tasks or SQL.
# Only admins with direct access to the db will be able to update these records
#
class Rate < UuidApplicationRecord
  include Licenses

  belongs_to :state_rule, polymorphic: true

  validates :name, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }
  validates :effective_on, date_param: true
  validates :expires_on, date_param: true, allow_nil: true
  validates :state, presence: true

  scope :active_on_date, ->(date) { where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc) }
end

# == Schema Information
#
# Table name: rates
#
#  id              :uuid             not null, primary key
#  county          :string
#  effective_on    :date
#  expires_on      :date
#  license_type    :string           not null
#  max_age         :decimal(, )      not null
#  name            :string           not null
#  state           :string
#  state_rule_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  state_rule_id   :uuid
#
# Indexes
#
#  state_rule_index  (state_rule_type,state_rule_id)
#
