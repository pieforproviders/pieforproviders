# frozen_string_literal: true

# Subsidy rules
# These records will be manually added to the db either through rake tasks or SQL.
# Only admins with direct access to the db will be able to update these records
#
class SubsidyRule < UuidApplicationRecord
  # rubocop:disable Rails/InverseOf
  belongs_to :county, class_name: 'Lookup::County', foreign_key: 'county_id'
  belongs_to :state, class_name: 'Lookup::State', foreign_key: 'state_id'
  # rubocop:enable Rails/InverseOf

  # TODO: when PR 252 is merged, use the enum license_type: ... and get rid of LICENSE_TYPES
  # enum license_type: Licenses.types
  LICENSE_TYPES = %w[
    licensed_center_single
    licensed_center_multi
    licensed_family_home
    licensed_group_home
    license_exempt_home
    license_exempt_center_single
    license_exempt_center_multi
  ].freeze

  enum license_type: LICENSE_TYPES.to_h { |s| [s, s] }

  validates :name, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }
  validates :full_day_rate, numericality: { greater_than_or_equal_to: 0.00 }
  validates :part_day_rate, numericality: { greater_than_or_equal_to: 0.00 }
  validates :full_day_max_hours, numericality: { greater_than_or_equal_to: 0.00 }
  validates :part_day_max_hours, numericality: { greater_than_or_equal_to: 0.00 }
  validates :full_day_threshold, numericality: { greater_than_or_equal_to: 0.00 }
  validates :part_day_threshold, numericality: { greater_than_or_equal_to: 0.00 }
  validates :full_plus_full_day_max_hours, numericality: { greater_than_or_equal_to: 0.00 }
  validates :full_plus_part_day_max_hours, numericality: { greater_than_or_equal_to: 0.00 }

  # validates :license_type, inclusion: { in: Licenses.types.values }  # TODO: use this when PR 252 is merged

  # The money-rails gem specifically requires that the '_cents' suffix be
  # specified when using the "monetize" macro even though the attributes are
  # referred to without the '_cents' suffix.
  # IOW, you only need to refer to part_day_rate.amount or payment.discrepancy ,
  # unlike the following statements.
  monetize :part_day_rate_cents
  monetize :full_day_rate_cents
end

# == Schema Information
#
# Table name: subsidy_rules
#
#  id                           :uuid             not null, primary key
#  full_day_max_hours           :decimal(, )      not null
#  full_day_rate_cents          :integer          default(0), not null
#  full_day_rate_currency       :string           default("USD"), not null
#  full_day_threshold           :decimal(, )      not null
#  full_plus_full_day_max_hours :decimal(, )      not null
#  full_plus_part_day_max_hours :decimal(, )      not null
#  max_age                      :decimal(, )      not null
#  name                         :string           not null
#  part_day_max_hours           :decimal(, )      not null
#  part_day_rate_cents          :integer          default(0), not null
#  part_day_rate_currency       :string           default("USD"), not null
#  part_day_threshold           :decimal(, )      not null
#  provider_type                :enum             not null
#  qris_rating                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  county_id                    :uuid             not null
#  state_id                     :uuid             not null
#
# Indexes
#
#  index_subsidy_rules_on_county_id  (county_id)
#  index_subsidy_rules_on_state_id   (state_id)
#
