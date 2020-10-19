# frozen_string_literal: true

require 'memoist'

# US States
class State < UuidApplicationRecord
  extend Memoist
  has_many :zipcodes, dependent: :restrict_with_error
  has_many :counties, dependent: :restrict_with_error

  validates :abbr, uniqueness: { case_sensitive: false }, presence: true
  validates :name, uniqueness: { case_sensitive: false }, presence: true

  def cities
    zipcodes.map(&:city).sort.uniq
  end
  memoize :cities
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
