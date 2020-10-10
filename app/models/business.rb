# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class Business < UuidApplicationRecord
  belongs_to :user
  belongs_to :zipcode
  belongs_to :county

  has_many :children, dependent: :restrict_with_error

  enum license_type: Licenses.types

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :active, -> { where(active: true) }
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  active       :boolean          default(TRUE), not null
#  license_type :enum
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  county_id    :uuid             not null
#  user_id      :uuid             not null
#  zipcode_id   :uuid             not null
#
# Indexes
#
#  index_businesses_on_county_id         (county_id)
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_user_id           (user_id)
#  index_businesses_on_zipcode_id        (zipcode_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (zipcode_id => zipcodes.id)
#
