# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class Business < UuidApplicationRecord
  include Licenses

  before_save :state_from_zipcode
  before_update :prevent_deactivation_with_active_children

  belongs_to :user

  has_many :children, dependent: :restrict_with_error

  accepts_nested_attributes_for :children

  QRIS_RATINGS = %w[
    not_rated
    step_one
    step_two
    step_three
    step_four
    step_five
    gold
    silver
    bronze
  ].freeze

  validates :active, inclusion: { in: [true, false] }
  validates :qris_rating, inclusion: { in: QRIS_RATINGS }, allow_nil: true
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :county, presence: true
  validates :zipcode, presence: true

  scope :active, -> { where(active: true) }

  def ne_qris_bump
    exponents = {
      step_one: 0,
      step_two: 0,
      step_three: accredited ? 0 : 1,
      step_four: accredited ? 1 : 2,
      step_five: accredited ? 2 : 3
    }
    exponent = qris_rating && exponents[qris_rating.to_sym] ? exponents[qris_rating.to_sym] : 0
    1.05**exponent # compounding qris formula
  end

  private

  def prevent_deactivation_with_active_children
    return unless children.pluck(:active).uniq.include?(true) && will_save_change_to_active?(from: true, to: false)

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
#  accredited   :boolean
#  active       :boolean          default(TRUE), not null
#  county       :string
#  deleted_at   :date
#  license_type :string           not null
#  name         :string           not null
#  qris_rating  :string
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
