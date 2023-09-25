# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class Business < UuidApplicationRecord
  include Licenses
  include QualityRatings
  IL = 'IL'

  before_save :state_from_zipcode
  before_create :set_default_schedules, if: proc { state == IL }
  before_update :prevent_deactivation_with_active_children

  belongs_to :user

  has_many :child_businesses, dependent: :destroy
  has_many :children, through: :child_businesses, dependent: :destroy
  has_many :child_approvals, through: :children, dependent: :destroy
  has_many :approvals, through: :child_approvals, dependent: :destroy
  has_many :business_schedules, dependent: :destroy
  has_many :business_closures, dependent: :destroy

  accepts_nested_attributes_for :children, :business_schedules, :business_closures

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :county, presence: true
  validates :zipcode, presence: true

  scope :active, -> { where(active: true) }

  scope :center, -> { where('license_type like ?', '%center%') }

  delegate 'eligible_by_date?', to: :child

  def ne_qris_bump(date: nil)
    # qris rating is used to determine reimbursement rates after 7/1/22
    # rather than being a multiplier
    return 1 if date && date >= '2022-07-01'.to_date

    exponent = quality_rating && exponents[quality_rating.to_sym] ? exponents[quality_rating.to_sym] : 0
    1.05**exponent # compounding qris formula
  end

  def eligible_by_date?(date)
    open_by_date?(date)
  end

  def license_center?
    license_type.include?('center')
  end

  def attendance_rate(child, date, eligible_days, attended_days)
    AttendanceRateCalculator.new(child, date, self, eligible_days:, attended_days:).call
  end

  def il_quality_bump
    case quality_rating
    when 'silver'
      1.1
    when 'gold'
      1.15
    else
      1
    end
  end

  private

  def exponents
    {
      step_one: 0,
      step_two: 0,
      step_three: accredited ? 0 : 1,
      step_four: accredited ? 1 : 2,
      step_five: accredited ? 2 : 3
    }
  end

  def prevent_deactivation_with_active_children
    return unless children.pluck(:active).uniq.include?(true) && will_save_change_to_active?(from: true, to: false)

    errors.add(:active, 'Cannot deactivate a business with active cases')
    throw :abort
  end

  def state_from_zipcode
    StateFinder.new(self).call
  end

  def set_default_schedules
    return if business_schedules.any?

    7.times do |day|
      business_schedules.build(business_schedule_default_param(day))
    end
  end

  def business_schedule_default_param(day)
    {
      weekday: day,
      is_open: !DateService.weekend?(day)
    }
  end

  def open_by_date?(date)
    weekday = date.wday
    closed_on_date = business_closures.where(date:).any?
    return false if closed_on_date

    open_on_date = business_schedules.where(weekday:, is_open: true).any?
    open_on_date = Holiday.where(date:).none? if open_on_date

    open_on_date
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id              :uuid             not null, primary key
#  accredited      :boolean
#  county          :string
#  deleted_at      :date
#  inactive_reason :string
#  license_type    :string           not null
#  name            :string           not null
#  quality_rating  :string
#  state           :string
#  zipcode         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :uuid             not null
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
