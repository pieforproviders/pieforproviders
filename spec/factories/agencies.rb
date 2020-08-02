# frozen_string_literal: true

FactoryBot.define do
  factory :agency do
    name { "Agency name" }
    state { "IL" }
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
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
