# frozen_string_literal: true

FactoryBot.define do
  factory :illinois_subsidy_rule do
    # set a decimal value 90% of the time; 10% set to nil
    bronze_percentage { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Number.decimal(l_digits: 2, r_digits: 2) : nil }
    silver_percentage { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Number.decimal(l_digits: 2, r_digits: 2) : nil }
    gold_percentage { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Number.decimal(l_digits: 2, r_digits: 2) : nil }
  end
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
