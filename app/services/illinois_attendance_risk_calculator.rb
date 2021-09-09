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
    return 'not_enough_info' if less_than_halfway_through_month || !approval_amount || !threshold

    attendance_rate = IllinoisAttendanceRateCalculator.new(@child, @filter_date).call

    if attendance_rate < threshold
      threshold_not_met_risks
    elsif attended_all_approved_days
      'sure_bet'
    else
      'on_track'
    end
  end

  def less_than_halfway_through_month
    Time.current < halfway || (latest_user_attendance && latest_user_attendance < halfway)
  end

  def approval_amount
    active_child_approval.illinois_approval_amounts.for_month(@filter_date).first
  end

  def attended_all_approved_days
    return false unless approval_amount

    must_attend_part_days = approval_amount.part_days_approved_per_week.positive?
    must_attend_full_days = approval_amount.full_days_approved_per_week.positive?
    (!must_attend_part_days || part_day_attendances.positive?) && (!must_attend_full_days || full_day_attendances.positive?)
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
    active_approval = @child.approvals.active_on_date(@filter_date).first
    (threshold * family_days_approved - family_days_attended) > active_approval.child_approvals.count * days_left_in_month
  end

  def at_risk
    family_days_attended.to_f / ((percentage_of_month_elapsed * family_days_approved).nonzero? || 1) < threshold
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
    active_child_approval&.rate&.attendance_threshold&.to_f
  end

  def latest_user_attendance
    @child.business.user.latest_attendance_in_month_utc(@filter_date)
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
end
