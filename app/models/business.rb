# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class Business < UuidApplicationRecord
  before_update :prevent_deactivation_with_active_children
  after_commit :state_from_zipcode

  belongs_to :user

  has_many :children, dependent: :restrict_with_error

  enum license_type: Licenses.types

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :county, presence: true
  validates :zipcode, presence: true

  scope :active, -> { where(active: true) }

  private

  def prevent_deactivation_with_active_children
    return unless children.pluck(:active).uniq.include?(true)

    errors.add(:active, 'Cannot deactivate a business with active cases')
    throw :abort
  end

  def state_from_zipcode
    StateFinder.new(self).call
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  active       :boolean          default(TRUE), not null
#  county       :string
#  license_type :string           not null
#  name         :string           not null
#  state        :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
