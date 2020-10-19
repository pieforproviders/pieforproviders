# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    abbr { Faker::Address.state_abbr }
    name { Faker::Address.state }
  end
end

# == Schema Information
#
# Table name: states
#
#  id         :uuid             not null, primary key
#  abbr       :string(2)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_states_on_abbr  (abbr)
#
