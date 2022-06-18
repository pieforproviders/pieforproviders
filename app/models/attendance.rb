# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
class Attendance < UuidApplicationRecord
  before_validation :round_check_in, :round_check_out, :calc_time_in_care
  # after_save_commit :update_dashboard

  belongs_to :child_approval
  belongs_to :service_day

  # Rails 6.2 will be returning an activesupport duration object for interval type fields
  # this uses the new behavior in advance of that release
  attribute :time_in_care, :interval

  accepts_nested_attributes_for :service_day

  validates :check_in, time_param: true, presence: true
  validates :check_out, time_param: true, unless: proc { |attendance| attendance.check_out_before_type_cast.nil? }
  validate :check_out_after_check_in

  scope :for_month,
        lambda { |month = nil|
          month ||= Time.current
          where('check_in BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month)
        }
  scope :for_week,
        lambda { |week = nil|
          week ||= Time.current
          where('check_in BETWEEN ? AND ?', week.at_beginning_of_week(:sunday), week.at_end_of_week(:sunday))
        }

  scope :for_day,
        lambda { |day = nil|
          day ||= Time.current
          where('check_in BETWEEN ? AND ?', day.at_beginning_of_day, day.at_end_of_day)
        }

  scope :illinois_part_days, -> { where('time_in_care < ?', '5 hours') }
  scope :illinois_full_days, -> { where('time_in_care BETWEEN ? AND ?', '5 hours', '12 hours') }
  scope :illinois_full_plus_part_days,
        lambda {
          where('time_in_care > ? AND time_in_care < ?', '12 hours', '17 hours')
        }
  scope :illinois_full_plus_full_days, -> { where('time_in_care BETWEEN ? AND ?', '17 hours', '24 hours') }

  delegate :business, to: :child_approval
  delegate :user, to: :child_approval
  delegate :child, to: :child_approval
  delegate :state, to: :child
  delegate :county, to: :child
  delegate :timezone, to: :user

  private

  def round_check_in
    return unless check_in

    self.check_in = Time.zone.at(check_in - check_in.sec)
  end

  def round_check_out
    return unless check_out

    self.check_out = Time.zone.at(check_out - check_out.sec)
  end

  def calc_time_in_care
    self.time_in_care = if check_in && check_out
                          check_out - check_in
                        else
                          0.seconds
                        end
  end

  def check_out_after_check_in
    return if check_out.blank? || check_in.blank?

    errors.add(:check_out, 'must be after the check in time') if check_out < check_in
  end

  # def update_dashboard
  #   DashboardUpdaterJob.perform_later(attendance: self)
  # end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                       :uuid             not null, primary key
#  absence                                                  :string
#  check_in                                                 :datetime         not null
#  check_out                                                :datetime
#  deleted_at                                               :date
#  time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                               :datetime         not null
#  updated_at                                               :datetime         not null
#  child_approval_id                                        :uuid             not null
#  service_day_id                                           :uuid
#  wonderschool_id                                          :string
#
# Indexes
#
#  index_attendances_on_absence            (absence)
#  index_attendances_on_check_in           (check_in)
#  index_attendances_on_child_approval_id  (child_approval_id)
#  index_attendances_on_service_day_id     (service_day_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#  fk_rails_...  (service_day_id => service_days.id)
#
