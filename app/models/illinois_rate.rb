# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class IllinoisRate < UuidApplicationRecord
  has_one :rate, as: :rateable, dependent: :restrict_with_error

  validates :bronze_percentage, numericality: true, allow_nil: true
  validates :full_day_rate, numericality: true, allow_nil: true
  validates :gold_percentage, numericality: true, allow_nil: true
  validates :part_day_rate, numericality: true, allow_nil: true
  validates :silver_percentage, numericality: true, allow_nil: true
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                   :uuid             not null, primary key
#  attendance_threshold :decimal(, )
#  bronze_percentage    :decimal(, )
#  full_day_rate        :decimal(, )
#  gold_percentage      :decimal(, )
#  part_day_rate        :decimal(, )
#  silver_percentage    :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
