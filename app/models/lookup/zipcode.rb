# frozen_string_literal: true

# US Zipcodes.  Used for lookup only.  Original source: my_zip_code gem
class Lookup::Zipcode < ApplicationRecord
  self.table_name = 'lookup_zipcodes'

  belongs_to :state
  belongs_to :county, optional: true
  belongs_to :city, optional: true

  validates :code, presence: true, uniqueness: true
  validates :state, presence: true
end

# == Schema Information
#
# Table name: lookup_zipcodes
#
#  id         :uuid             not null, primary key
#  area_code  :string
#  code       :string           not null
#  lat        :decimal(15, 10)
#  lon        :decimal(15, 10)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city_id    :uuid
#  county_id  :uuid
#  state_id   :uuid
#
# Indexes
#
#  index_lookup_zipcodes_on_city_id               (city_id)
#  index_lookup_zipcodes_on_code                  (code) UNIQUE
#  index_lookup_zipcodes_on_county_id             (county_id)
#  index_lookup_zipcodes_on_state_id              (state_id)
#  index_lookup_zipcodes_on_state_id_and_city_id  (state_id,city_id)
#
