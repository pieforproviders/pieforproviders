# frozen_string_literal: true

# The sites at which businesses have children in care
class Site < UuidApplicationRecord
  belongs_to :business
  has_many :child_sites, dependent: :destroy
  has_many :children, through: :child_sites

  belongs_to :city, class_name: 'Lookup::City'
  belongs_to :zip, class_name: 'Lookup::Zipcode'
  belongs_to :county, class_name: 'Lookup::County'
  belongs_to :state, class_name: 'Lookup::State'

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: { scope: :business_id }
  validates :address, presence: true

  scope :active, -> { where(active: true) }

  delegate :user, to: :business
end

# == Schema Information
#
# Table name: sites
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  address     :string           not null
#  name        :string           not null
#  qris_rating :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#  city_id     :uuid             not null
#  county_id   :uuid             not null
#  state_id    :uuid             not null
#  zip_id      :uuid             not null
#
# Indexes
#
#  index_sites_on_name_and_business_id  (name,business_id) UNIQUE
#
