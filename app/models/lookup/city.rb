# frozen_string_literal: true

# US Cities.  Used for lookup only.
class Lookup::City < ApplicationRecord
  self.table_name = 'lookup_cities'

  belongs_to :state
  belongs_to :county, optional: true

  validates :state, presence: true
  validates :name, presence: true,
                   uniqueness: { scope: :state_id, case_sensitive: false }
end

# == Schema Information
#
# Table name: lookup_cities
#
#  id        :uuid             not null, primary key
#  name      :string           not null
#  county_id :uuid
#  state_id  :uuid             not null
#
# Indexes
#
#  index_lookup_cities_on_county_id          (county_id)
#  index_lookup_cities_on_name               (name)
#  index_lookup_cities_on_name_and_state_id  (name,state_id) UNIQUE
#  index_lookup_cities_on_state_id           (state_id)
#
