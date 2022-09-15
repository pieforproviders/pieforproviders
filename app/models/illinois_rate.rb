# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class IllinoisRate < UuidApplicationRecord
  include Licenses

  has_many :child_approvals, as: :rate, dependent: :restrict_with_error

  validates :name, presence: true
  validates :region, presence: true
  validates :age_bucket, numericality: { greater_than_or_equal_to: 0.00 }, presence: true
  validates :effective_on, date_param: true, presence: true
  validates :expires_on,
            date_param: true,
            unless: proc { |illinois_rate|
                      illinois_rate.expires_on_before_type_cast.nil?
                    }

  scope :active_on,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc)
        }
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id           :uuid             not null, primary key
#  age_bucket   :decimal(, )      default(0.0), not null
#  deleted_at   :date
#  effective_on :date             not null
#  expires_on   :date
#  license_type :string           default("licensed_family_home"), not null
#  name         :string           default("Rule Name Filler"), not null
#  rate_type    :string           not null
#  region       :string           default(" "), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_illinois_rates_on_effective_on  (effective_on)
#  index_illinois_rates_on_expires_on    (expires_on)
#
