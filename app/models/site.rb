# frozen_string_literal: true

# The sites at which businesses have children in care
class Site < UuidApplicationRecord
  belongs_to :business
  has_many :child_sites, dependent: :destroy
  has_many :children, through: :child_sites

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: { scope: :business_id }
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :county, presence: true

  before_validation { |site| site.slug = generate_slug("#{site.name}#{site.business_id}") }
end

# == Schema Information
#
# Table name: sites
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  address     :string           not null
#  city        :string           not null
#  county      :string           not null
#  name        :string           not null
#  qris_rating :string
#  slug        :string           not null
#  state       :string           not null
#  zip         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_sites_on_name_and_business_id  (name,business_id) UNIQUE
#
