# frozen_string_literal: true

# Subsidy rules - polymorphic "parent" class
# These records will be manually added to the db either through rake tasks or SQL.
# Only admins with direct access to the db will be able to update these records
#
class SubsidyRule < UuidApplicationRecord
  belongs_to :county, optional: true
  belongs_to :state
  belongs_to :subsidy_ruleable, polymorphic: true
  has_many :subsidy_rule_rate_types, dependent: :destroy
  has_many :rate_types, through: :subsidy_rule_rate_types

  enum license_type: Licenses.types

  validates :name, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }
  validates :effective_on, date_param: true
  validates :expires_on, date_param: true

  validates :license_type, inclusion: { in: Licenses.types.values }

  def self.in_effect_on(date = Date.current)
    where('effective_on <= ?', date).where('expires_on > ?', date)
  end

  def self.within_max_age(age)
    where('max_age >= ?', age).order(:max_age)
  end

  def self.age_county_state(age, county, state, effective_on: Date.current)
    in_effect_on(effective_on)
      .where(state: state, county: county)
      .within_max_age(age)
      .first
  end
end
# == Schema Information
#
# Table name: subsidy_rules
#
#  id                    :uuid             not null, primary key
#  effective_on          :date
#  expires_on            :date
#  license_type          :enum             not null
#  max_age               :decimal(, )      not null
#  name                  :string           not null
#  subsidy_ruleable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  county_id             :uuid
#  state_id              :uuid             not null
#  subsidy_ruleable_id   :uuid
#
# Indexes
#
#  index_subsidy_rules_on_county_id               (county_id)
#  index_subsidy_rules_on_state_id                (state_id)
#  index_subsidy_rules_on_state_id_and_county_id  (state_id,county_id)
#  subsidy_ruleable_index                         (subsidy_ruleable_type,subsidy_ruleable_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (state_id => states.id)
#
