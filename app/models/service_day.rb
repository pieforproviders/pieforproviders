# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class ServiceDay < UuidApplicationRecord
  belongs_to :child
  has_many :attendances, dependent: :destroy

  validates :date, date_time_param: true, presence: true

  scope :for_month,
        lambda { |month = nil|
          month ||= Time.current
          where('date BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month)
        }
  scope :for_week,
        lambda { |week = nil|
          week ||= Time.current
          where('date BETWEEN ? AND ?', week.at_beginning_of_week(:sunday), week.at_end_of_week(:saturday))
        }

  scope :for_day,
        lambda { |day = nil|
          day ||= Time.current
          where('date BETWEEN ? AND ?', day.at_beginning_of_day, day.at_end_of_day)
        }

  delegate :business, to: :child

  def total_time_in_care
    attendances.sum(&:total_time_in_care)
  end

  def absence?
    attendances.any?(&:absence)
  end

  # TODO: this is too complex but I don't know how to improve it without
  # arbitrarily splitting out scopes
  def rates
    # eventually this will be a more in-depth conditional
    return nil unless business.state == 'NE'

    NebraskaRate
      .active_on_date(check_in)
      .by_region(business.nebraska_region)
      .by_license_type(business.license_type)
      .by_accredited_rate(business.accredited)
      .by_school_enrollment(child_approval.enrolled_in_school)
      .by_age(child.age_in_months(date))
      .order_max_age
  end

  def child_approval
    child.active_child_approval(date)
  end
end

# == Schema Information
#
# Table name: service_days
#
#  id         :uuid             not null, primary key
#  date       :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_service_days_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
