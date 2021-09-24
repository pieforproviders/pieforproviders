# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class IllinoisRate < UuidApplicationRecord
  include Licenses

  has_many :child_approvals, as: :rate, dependent: :restrict_with_error

  validates :name, presence: true
  validates :county, presence: true
  validates :max_age, numericality: { greater_than_or_equal_to: 0.00 }, presence: true
  validates :effective_on, date_param: true, presence: true
  validates :expires_on,
            date_param: true,
            unless: proc { |illinois_rate|
                      illinois_rate.expires_on_before_type_cast.nil?
                    }
  validates :bronze_percentage, numericality: true, allow_nil: true
  validates :full_day_rate, numericality: true, allow_nil: true
  validates :gold_percentage, numericality: true, allow_nil: true
  validates :part_day_rate, numericality: true, allow_nil: true
  validates :silver_percentage, numericality: true, allow_nil: true

  scope :active_on_date,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc)
        }
end

# == Schema Information
#
# Table name: illinois_rates
#
#  id                   :uuid             not null, primary key
#  attendance_threshold :decimal(, )
#  bronze_percentage    :decimal(, )
#  county               :string           default(" "), not null
#  effective_on         :date             not null
#  expires_on           :date
#  full_day_rate        :decimal(, )
#  gold_percentage      :decimal(, )
#  license_type         :string           default("licensed_family_home"), not null
#  max_age              :decimal(, )      default(0.0), not null
#  name                 :string           default("Rule Name Filler"), not null
#  part_day_rate        :decimal(, )
#  silver_percentage    :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
