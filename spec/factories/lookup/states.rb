# frozen_string_literal: true

FactoryBot.define do
  factory :state, class: Lookup::State do
    name { Faker::Address.state }
    abbr do
      # Faker::Address doesn't have a method to return the abbreviation for a given state
      state_number = Faker::Address.fetch_all('address.state').find_index(name)
      Faker::Address.fetch_all('address.state_abbr')[state_number]
    end
  end
end

# == Schema Information
#
# Table name: lookup_states
#
#  id         :uuid             not null, primary key
#  abbr       :string(2)        not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_lookup_states_on_abbr  (abbr) UNIQUE
#  index_lookup_states_on_name  (name) UNIQUE
#
