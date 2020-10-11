# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
#
# from GitHub comments on the PR to implement this model (PR 320)
# 2020-09-08: open question from Kate D.:
#   When someone adds an attendance, are we expecting them to choose what
#   length of care it is, or are we calculating that by the number of hours
#   as laid out in their subsidy rule?
#   If we're calculating it, can the user change it, if for some reason our
#   calculation gets it wrong?
#
#   2020-09-08: Answer from Chelsea S:
#   Since we haven't designed these screens yet, I don't think we have clear
#   answers. My assumption, though, is that we're calculating it for them based
#   on the number of hours, as laid out in their subsidy rule.
#   I'm not sure if we'll let them change it.
#
class Attendance < UuidApplicationRecord
  DURATION_DEFINITIONS = %w[part_day full_day full_plus_part_day full_plus_full_day].freeze
  enum attendance_duration: DURATION_DEFINITIONS.index_by(&:to_sym)

  before_validation :calc_total_time_in_care

  validates :starts_on, date_param: true
  validates :check_in, time_param: true
  validates :check_out, time_param: true

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
#  attendance_duration                                            :enum             default("full_day"), not null
#  check_in                                                       :time             not null
#  check_out                                                      :time             not null
#  starts_on                                                      :date             not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#
