# frozen_string_literal: true

# US Zipcodes.  Used for lookup only.  Source:  my_zip_code gem
class Lookups::Zipcode < ApplicationRecord
  self.table_name = 'zipcodes' # TODO: do we want the table to be named 'lookups_states' ?

  belongs_to :county
  belongs_to :state

  validates :code, uniqueness: true, presence: true
  validates :state_id, :county_id, :city, presence: true

  scope :without_county, -> { where("county_id IS NULL") }
  scope :without_state, -> { where("state_id IS NULL") }
  scope :ungeocoded, -> { where("lat IS NULL OR lon IS NULL") }

  class << self
    def find_by_city_state(city, state)
      includes(county: :state)
        .where("city like ? AND states.abbr like ?", "#{city}%", "%#{state}%")
        .references(:state)
        .first
    end

    def find_all_by_city_state(city, state)
      includes(county: :state)
        .where("city like ? AND states.abbr like ?", "#{city}%", "%#{state}%")
        .references(:state)
    end
  end

  def latlon
    [lat, lon]
  end

  def geocoded?
    (!lat.nil? && !lon.nil?)
  end
end

# == Schema Information
#
# Table name: zipcodes
#
#  id         :uuid             not null, primary key
#  area_code  :string
#  city       :string
#  code       :string
#  lat        :decimal(15, 10)
#  lon        :decimal(15, 10)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  county_id  :uuid
#  state_id   :uuid
#
# Indexes
#
#  index_zipcodes_on_code         (code)
#  index_zipcodes_on_county_id    (county_id)
#  index_zipcodes_on_lat_and_lon  (lat,lon)
#  index_zipcodes_on_state_id     (state_id)
#
