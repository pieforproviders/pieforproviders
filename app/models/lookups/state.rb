# frozen_string_literal: true

require 'memoist'

# US States.  Used for lookup only.  Source:  my_zip_code gem
module Lookups
  class State < ApplicationRecord
    self.table_name = 'states' # TODO: do we want the table to be named 'lookups_states' ?

    extend Memoist
    has_many :zipcodes
    has_many :counties

    validates :abbr, uniqueness: { case_sensitive: false }, presence: true
    validates :name, uniqueness: { case_sensitive: false }, presence: true


    def cities
      zipcodes.map(&:city).sort.uniq
    end


    memoize :cities
  end
end
# == Schema Information
#
# Table name: states
#
#  id         :uuid             not null, primary key
#  abbr       :string(2)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_states_on_abbr  (abbr)
#
