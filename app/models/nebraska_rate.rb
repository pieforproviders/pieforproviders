# frozen_string_literal: true

# Subsidy rules that apply for Nebraska
class NebraskaRate < UuidApplicationRecord
  include Licenses

  has_many :child_approvals, as: :rate, dependent: :restrict_with_error

  TYPES = %w[
    daily
    hourly
  ].freeze

  REGIONS = %w[
    All
    LDDS
    Lancaster-Dakota
    Douglas-Sarpy
    Other
  ].freeze

  validates :rate_type, inclusion: { in: TYPES }
  validates :region, inclusion: { in: REGIONS }
  validates :name, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }, allow_nil: true
  validates :amount, numericality: { greater_than_or_equal_to: 0.00 }, presence: true
  validates :effective_on, date_param: true, presence: true
  validates :expires_on,
            date_param: true,
            unless: proc { |nebraska_rate|
                      nebraska_rate.expires_on_before_type_cast.nil?
                    }

  scope :active_on,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc)
        }

  scope :hourly, -> { where(rate_type: 'hourly') }
  scope :daily, -> { where(rate_type: 'daily') }
  scope :order_max_age, -> { reorder('max_age ASC NULLS LAST') }
end

# == Schema Information
#
# Table name: nebraska_rates
#
#  id              :uuid             not null, primary key
#  accredited_rate :boolean          default(FALSE), not null
#  amount          :decimal(, )      not null
#  county          :string
#  deleted_at      :date
#  effective_on    :date             not null
#  expires_on      :date
#  license_type    :string           not null
#  max_age         :decimal(, )
#  name            :string           not null
#  rate_type       :string           not null
#  region          :string           not null
#  school_age      :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
