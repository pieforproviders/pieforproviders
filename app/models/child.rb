# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < UuidApplicationRecord
  belongs_to :business

  has_many :child_approvals, dependent: :destroy
  has_many :approvals, through: :child_approvals

  validates :active, inclusion: { in: [true, false] }
  validates :date_of_birth, presence: true
  validates :full_name, presence: true
  validates :full_name, uniqueness: { scope: %i[date_of_birth business_id] }

  validates :approvals, presence: true

  validates :date_of_birth, date_param: true

  accepts_nested_attributes_for :approvals

  scope :active, -> { where(active: true) }

  delegate :user, to: :business

  # @return [Decimal] - the age of the child in years on the given date,
  #  rounded to 4 decimal places
  def age_in_years(given_date = Date.current)
    years = given_date.year - date_of_birth.year
    days_since = days_since_recent_birthday(given_date)

    divisor = 365.0
    divisor += 1 if DateHelperService.leap_day_btwn?(recent_birthday, given_date)

    partial_year = (days_since / divisor).round(4)
    years + partial_year
  end

  private

  # @return [Integer] - number of days since the most recent birthday
  def days_since_recent_birthday(given_date = Date.current)
    (given_date - recent_birthday(given_date)).to_i
  end

  # @return [Date] - the most recent birthday to have already occurred on or
  #   before the given_date
  def recent_birthday(given_date = Date.current)
    bd_in_given_year = date_of_birth.change(year: given_date.year)

    # Has the most recent birthday already happened in the given year?
    recent_bd_year = (bd_in_given_year > given_date ? given_date.year - 1 : given_date.year)
    date_of_birth.change(year: recent_bd_year)
  end
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  business_id   :uuid             not null
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
