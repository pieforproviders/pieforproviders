# frozen_string_literal: true

require 'memoist'

# US Counties
class County < UuidApplicationRecord
  extend Memoist
  belongs_to :state
  has_many :zipcodes, dependent: :restrict_with_error

  validates :name, uniqueness: { scope: :state_id, case_sensitive: false },
                   presence: true

  scope :without_zipcodes, -> { where('id NOT IN (SELECT DISTINCT(county_id) FROM zipcodes)') }
  scope :without_state, -> { where(state_id: nil) }

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
#  state_id    :uuid             not null
#
# Indexes
#
#  index_counties_on_name      (name)
#  index_counties_on_state_id  (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#
