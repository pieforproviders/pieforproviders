# frozen_string_literal: true

# US States.  Used for lookup only.  original source:  my_zip_code gem
class Lookup::State < ApplicationRecord
  self.table_name = 'lookup_states'

  has_many :counties, dependent: :destroy
  has_many :cities, dependent: :destroy
  has_many :zipcodes, dependent: :destroy

  validates :abbr, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
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
