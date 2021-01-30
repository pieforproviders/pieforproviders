# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
class Attendance < UuidApplicationRecord
  before_validation :calc_total_time_in_care

  belongs_to :child_approval

  attribute :total_time_in_care, :interval

  validates :check_in, time_param: true
  validates :check_out, time_param: true

  scope :for_month, ->(month = DateTime.now) { where('check_in BETWEEN ? AND ?', month.at_beginning_of_month, month.at_end_of_month) }

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
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime         not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
