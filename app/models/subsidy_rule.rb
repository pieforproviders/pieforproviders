# frozen_string_literal: true

# Subsidy rules
# These records will be manually added to the db either through rake tasks or SQL.
# Only admins with direct access to the db will be able to update these records
#
class SubsidyRule < UuidApplicationRecord
  enum license_type: Licenses.types

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

  validates :license_type, inclusion: { in: Licenses.types.values }

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
#  license_type                 :enum             not null
#  max_age                      :decimal(, )      not null
#  name                         :string           not null
#  part_day_max_hours           :decimal(, )      not null
#  part_day_rate_cents          :integer          default(0), not null
#  part_day_rate_currency       :string           default("USD"), not null
#  part_day_threshold           :decimal(, )      not null
#  qris_rating                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
