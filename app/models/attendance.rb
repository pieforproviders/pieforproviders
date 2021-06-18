# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
class Attendance < UuidApplicationRecord
  before_validation :calc_total_time_in_care

  belongs_to :child_approval

  # Rails 6.2 will be returning an activesupport duration object for interval type fields
  # this uses the new behavior in advance of that release
  attribute :total_time_in_care, :interval

  validates :check_in, time_param: true, presence: true
  validates :check_out, time_param: true, unless: proc { |attendance| attendance.check_out_before_type_cast.nil? }

  ABSENCE_TYPES = %w[
    absence
    covid_absence
  ].freeze

  validates :absence, inclusion: { in: ABSENCE_TYPES }, allow_nil: true

  scope :for_month, lambda { |month = nil|
    month ||= Time.current
    where('check_in BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month)
  }
  scope :for_week, lambda { |week = nil|
    week ||= Time.current
    where('check_in BETWEEN ? AND ?', week.at_beginning_of_week, week.at_end_of_week)
  }

  scope :illinois_part_days, -> { where('total_time_in_care < ?', '5 hours') }
  scope :illinois_full_days, -> { where('total_time_in_care BETWEEN ? AND ?', '5 hours', '12 hours') }
  scope :illinois_full_plus_part_days, -> { where('total_time_in_care > ? AND total_time_in_care < ?', '12 hours', '17 hours') }
  scope :illinois_full_plus_full_days, -> { where('total_time_in_care BETWEEN ? AND ?', '17 hours', '24 hours') }

  private

  def calc_total_time_in_care
    self.total_time_in_care = (check_out.nil? || check_in.nil? ? 0 : check_out - check_in)
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  absence                                                        :string
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#  wonderschool_id                                                :string
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
