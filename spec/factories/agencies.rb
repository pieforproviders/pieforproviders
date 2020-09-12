# frozen_string_literal: true

FactoryBot.define do
  factory :agency do
    name { Faker::Name.agencies }
    state { CreateOrSampleLookup.state }
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
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_agencies_on_name_and_state_id  (name,state_id) UNIQUE
#
