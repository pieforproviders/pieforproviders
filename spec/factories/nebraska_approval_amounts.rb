# frozen_string_literal: true

FactoryBot.define do
  factory :nebraska_approval_amount do
    allocated_family_fee { Faker::Number.decimal(l_digits: 2) }
    effective_on { (Time.current - 9.months).to_date }
    expires_on { effective_on + 1.year }
    family_fee { Faker::Number.decimal(l_digits: 2) }
    child_approval
  end
end
