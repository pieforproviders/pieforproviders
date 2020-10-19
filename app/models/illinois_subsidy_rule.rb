# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class IllinoisSubsidyRule < UuidApplicationRecord
  has_one :subsidy_rule, as: :subsidy_ruleable, dependent: :restrict_with_error
end

# == Schema Information
#
# Table name: illinois_subsidy_rules
#
#  id                :uuid             not null, primary key
#  bronze_percentage :decimal(, )
#  gold_percentage   :decimal(, )
#  silver_percentage :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
