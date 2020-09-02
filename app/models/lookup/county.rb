# frozen_string_literal: true

# US Counties.  Used for lookup only.  Source:  my_zip_code gem
class Lookup::County < ApplicationRecord
  self.table_name = 'lookup_counties'

  belongs_to :state
  has_many :zipcodes # rubocop:disable Rails/HasManyOrHasOneDependent

  validates :name, presence: true,
                   uniqueness: { scope: :state_id, case_sensitive: false }
end

# == Schema Information
#
# Table name: lookup_counties
#
#  id          :uuid             not null, primary key
#  abbr        :string
#  county_seat :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state_id    :uuid
#
# Indexes
#
#  index_lookup_counties_on_name               (name)
#  index_lookup_counties_on_state_id           (state_id)
#  index_lookup_counties_on_state_id_and_name  (state_id,name) UNIQUE
#
