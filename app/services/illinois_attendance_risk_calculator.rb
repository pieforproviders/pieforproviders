# frozen_string_literal: true

# Service to calculate a family's attendance rate
class IllinoisAttendanceRiskCalculator
  def initialize(child, filter_date)
    @child = child
    @filter_date = filter_date || Time.current
  end

  def call
    risk_label
  end

  private

  def active_child_approval
    @child.active_child_approval(@filter_date)
  end

  def attendances
    active_child_approval.attendances.for_month(@filter_date)
  end

  def risk_label
    partial_attendance_rate = attendance_rate_until_date * 100
    return 'not_enough_info' if partial_attendance_rate.zero? || less_than_halfway_through_month || !approval_amount

    if partial_attendance_rate < threshold
      'at_risk'
    else
      'on_track'
    end
  end

  def less_than_halfway_through_month
    Time.current < halfway
  end

  def approval_amount
    active_child_approval.illinois_approval_amounts.for_month(@filter_date).first
  end

  def attended_all_approved_days
    return false unless approval_amount

    must_attend_part_days = approval_amount.part_days_approved_per_week.positive?
    must_attend_full_days = approval_amount.full_days_approved_per_week.positive?
    (!must_attend_part_days || part_day_attendances.positive?) &&
      (!must_attend_full_days || full_day_attendances.positive?)
  end

  def threshold_not_met_risks
    if wont_meet_threshold
      'not_met'
    elsif at_risk
      'at_risk'
    else
      'on_track'
    end
  end

  def wont_meet_threshold
    active_approval = @child.approvals.active_on(@filter_date).first
    (
      (threshold / 100 * family_days_approved) - family_days_attended
    ) > active_approval.child_approvals.count * days_left_in_month
  end

  def at_risk
    family_days_attended.to_f / ((percentage_of_month_elapsed * family_days_approved).nonzero? || 1) < threshold / 100
  end

  def part_day_attendances
    attendances.illinois_part_days.count + attendances.illinois_full_plus_part_days.count
  end

  def full_day_attendances
    attendances.illinois_full_days.count + attendances.illinois_full_plus_full_days.count
  end

  def percentage_of_month_elapsed
    days_elapsed_in_month = @filter_date.day - @filter_date.at_beginning_of_month.day
    days_elapsed_in_month.to_f / total_days_in_month
  end

  def family_days_attended
    IllinoisAttendanceRateCalculator.new(@child, @filter_date).family_days_attended
  end

  def family_days_approved
    IllinoisAttendanceRateCalculator.new(@child, @filter_date).family_days_approved
  end

  def threshold
    69.5
    # TODO: attendance_threshold doesn't exist
    # active_child_approval&.rate&.attendance_threshold&.to_f
  end

  def latest_user_attendance
    @child.business.user.latest_service_day_in_month(@filter_date)
  end

  def halfway
    @filter_date.at_beginning_of_month + 14.days
  end

  def days_left_in_month
    @filter_date.at_end_of_month.day - @filter_date.day
  end

  def total_days_in_month
    @filter_date.to_date.all_month.count
  end

  def elapsed_eligible_days
    elapsed_days = @filter_date.day - @filter_date.at_beginning_of_month.day
    closed_days = Illinois::EligibleDaysCalculator.new(date: @filter_date, child: @child, until_given_date: true).closed_days_by_month_until_date

    elapsed_days - closed_days
  end

  def attended_days
    full_days = @child.service_days.for_month(@filter_date).map(&:full_time).compact.reduce(:+) || 0
    part_days = @child.service_days.for_month(@filter_date).map(&:part_time).compact.reduce(:+) || 0
    full_days + part_days
  end

  def attendance_rate_until_date
    (attended_days.to_f / elapsed_eligible_days).round(3)
  end
end
