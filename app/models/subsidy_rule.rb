# frozen_string_literal: true

# Subsidy rules
# These records will be manually added to the db either through rake tasks or SQL.
# Only admins with direct access to the db will be able to update these records
#
class SubsidyRule < UuidApplicationRecord
  belongs_to :county, optional: true
  belongs_to :state

  enum license_type: Licenses.types

  validates :name, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }

  validates :license_type, inclusion: { in: Licenses.types.values }
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id           :uuid             not null, primary key
#  license_type :enum             not null
#  max_age      :decimal(, )      not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  county_id    :uuid
#  state_id     :uuid             not null
#
# Indexes
#
#  index_subsidy_rules_on_county_id  (county_id)
#  index_subsidy_rules_on_state_id   (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (state_id => states.id)
#
