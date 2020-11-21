# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class IllinoisSubsidyRule < UuidApplicationRecord
  has_one :subsidy_rule, as: :subsidy_ruleable, dependent: :restrict_with_error

  validates :bronze_percentage, numericality: true
  validates :full_day_rate, numericality: true
  validates :gold_percentage, numericality: true
  validates :part_day_rate, numericality: true
  validates :silver_percentage, numericality: true
end

# == Schema Information
#
# Table name: illinois_subsidy_rules
#
#  id                :uuid             not null, primary key
#  bronze_percentage :decimal(, )
#  full_day_rate     :decimal(, )
#  gold_percentage   :decimal(, )
#  part_day_rate     :decimal(, )
#  silver_percentage :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
