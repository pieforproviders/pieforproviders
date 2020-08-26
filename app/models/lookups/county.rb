# frozen_string_literal: true

require 'memoist'

# US Counties.  Used for lookup only.  Source:  my_zip_code gem
class Lookups::County < ApplicationRecord
  self.table_name = 'counties' # TODO: do we want the table to be named 'lookups_states' ?

  extend Memoist
  belongs_to :state
  has_many :zipcodes

  validates :name, uniqueness: { scope: :state_id, case_sensitive: false },
            presence: true

  scope :without_zipcodes, lambda {
    county = County.arel_table
    zipcodes = Zipcode.arel_table
    zipjoin = county
              .join(zipcodes, Arel::Nodes::OuterJoin)
              .on(zipcodes[:county_id].eq(county[:id]))
    joins(zipjoin.join_sources).where(zipcodes[:county_id].eq(nil))
  }
  scope :without_state, lambda {
    where(state_id: nil)
  }

  def cities
    zipcodes.map(&:city).sort.uniq
  end

  memoize :cities
end

# == Schema Information
#
# Table name: counties
#
#  id          :uuid             not null, primary key
#  abbr        :string
#  county_seat :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state_id    :uuid
#
# Indexes
#
#  index_counties_on_name      (name)
#  index_counties_on_state_id  (state_id)
#
