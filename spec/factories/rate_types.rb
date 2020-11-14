# frozen_string_literal: true

FactoryBot.define do
  factory :rate_type do
    # set a decimal value 90% of the time; 10% set to nil
    name { Faker::Construction.subcontract_category }
    amount { Faker::Number.between(from: 1000, to: 10_000) }
    max_duration { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    threshold { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end

# == Schema Information
#
# Table name: rate_types
#
#  id              :uuid             not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  max_duration    :decimal(, )
#  name            :string           not null
#  threshold       :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
