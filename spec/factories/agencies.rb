# frozen_string_literal: true

FactoryBot.define do
  factory :agency do
    name { Faker::Name.agencies }
    state { Faker::Address.state_abbr }
    active { true }
  end
end

# == Schema Information
#
# Table name: agencies
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  name       :string           not null
#  state      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
