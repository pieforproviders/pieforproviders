# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
class Attendance < UuidApplicationRecord
  before_validation :calc_total_time_in_care, if: :child_approval

  belongs_to :child_approval

  # Rails 6.2 will be returning an activesupport duration object for interval type fields
  # this uses the new behavior in advance of that release
  attribute :total_time_in_care, :interval

  validates :check_in, time_param: true, presence: true
  validates :check_out, time_param: true, unless: proc { |attendance| attendance.check_out_before_type_cast.nil? }
  validate :check_out_after_check_in

  ABSENCE_TYPES = %w[
    absence
    covid_absence
  ].freeze

  validates :absence, inclusion: { in: ABSENCE_TYPES }, allow_nil: true

  validate :prevent_creation_of_absence_without_schedule

  scope :for_month, lambda { |month = nil|
    month ||= Time.current
    where('check_in BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month)
  }
  scope :for_week, lambda { |week = nil|
    week ||= Time.current
    where('check_in BETWEEN ? AND ?', week.at_beginning_of_week(:sunday), week.at_end_of_week(:saturday))
  }

  scope :illinois_part_days, -> { where('total_time_in_care < ?', '5 hours') }
  scope :illinois_full_days, -> { where('total_time_in_care BETWEEN ? AND ?', '5 hours', '12 hours') }
  scope :illinois_full_plus_part_days, -> { where('total_time_in_care > ? AND total_time_in_care < ?', '12 hours', '17 hours') }
  scope :illinois_full_plus_full_days, -> { where('total_time_in_care BETWEEN ? AND ?', '17 hours', '24 hours') }

  private

  def calc_total_time_in_care
    self.total_time_in_care = if check_in && check_out
                                check_out - check_in
                              elsif child_approval.child.state == 'NE'
                                calculate_from_schedule
                              else
                                0.seconds
                              end
  end

  def prevent_creation_of_absence_without_schedule
    return unless absence

    errors.add(:absence, "can't create for a day without a schedule") unless schedule_for_weekday
  end

  def calculate_from_schedule
    return 8.hours unless schedule_for_weekday

    schedule_for_weekday.end_time.on(check_in.to_date) - schedule_for_weekday.start_time.on(check_in.to_date)
  end

  def schedule_for_weekday
    child_approval.child.schedules.active_on_date(check_in.to_date).for_weekday(check_in.wday).first
  end

  def check_out_after_check_in
    return if check_out.blank? || check_in.blank?

    errors.add(:check_out, 'must be after the check in time') if check_out < check_in
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
