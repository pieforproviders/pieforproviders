# frozen_string_literal: true

# Subsidy rules - polymorphic "parent" class
# These records will be manually added to the db either through rake tasks or SQL.
# Only admins with direct access to the db will be able to update these records
#
class SubsidyRule < UuidApplicationRecord
  belongs_to :subsidy_ruleable, polymorphic: true

  enum license_type: Licenses.types

  validates :name, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }
  validates :effective_on, date_param: true
  validates :expires_on, date_param: true, allow_nil: true
  validates :state, presence: true

  validates :license_type, inclusion: { in: Licenses.types.values }

  scope :current, -> { where('effective_on <= ?', Date.current).where('expires_on IS NULL OR expires_on > ?', Date.current) }
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                    :uuid             not null, primary key
#  county                :string
#  effective_on          :date
#  expires_on            :date
#  license_type          :string           not null
#  max_age               :decimal(, )      not null
#  name                  :string           not null
#  state                 :string
#  subsidy_ruleable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  subsidy_ruleable_id   :uuid
#
# Indexes
#
#  subsidy_ruleable_index  (subsidy_ruleable_type,subsidy_ruleable_id)
#
