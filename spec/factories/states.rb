# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    abbr { Faker::Address.state_abbr }
    name { Faker::Address.state }
    initialize_with { State.find_or_create_by(name: name, abbr: abbr) }
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
#  index_states_on_abbr  (abbr) UNIQUE
#  index_states_on_name  (name) UNIQUE
#
