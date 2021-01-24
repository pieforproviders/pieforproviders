# frozen_string_literal: true

# Service to calculate a family's attendance rate
class IllinoisAttendanceRiskCalculator
  def initialize(child, from_date)
    @child = child
    @from_date = from_date
  end

  def call
    less_than_halfway_through_month = time_now < halfway || (latest_user_attendance && latest_user_attendance < halfway)
    return 'not_enough_info' if less_than_halfway_through_month

    risk_label
  end

  private

  def timezone
    @child.timezone
  end

  def active_child_approval
    @child.active_child_approval(@from_date)
  end

  def attendances
    active_child_approval.attendances.for_month(@from_date)
  end

  def risk_label
    attendance_rate = IllinoisAttendanceRateCalculator.new(@child, @from_date).call

    if attendance_rate < threshold
      threshold_not_met_risks
    elsif attended_all_approved_days
      'sure_bet'
    else
      'on_track'
    end
  end

  def attended_all_approved_days
    approval_amount = active_child_approval.illinois_approval_amounts.for_month(@from_date)
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
    active_approval = @child.approvals.active_on_date(@from_date.in_time_zone(timezone))
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
    days_elapsed_in_month = @from_date.day - @from_date.at_beginning_of_month.day
    days_elapsed_in_month.to_f / total_days_in_month
  end

  def family_days_attended
    IllinoisAttendanceRateCalculator.new(@child, @from_date).family_days_attended
  end

  def family_days_approved
    IllinoisAttendanceRateCalculator.new(@child, @from_date).family_days_approved
  end

  def time_now
    DateTime.now.in_time_zone(timezone)
  end

  def threshold
    active_child_approval.subsidy_rule.subsidy_ruleable.attendance_threshold.to_f
  end

  def latest_user_attendance
    @child.business.user.latest_attendance_in_month(@from_date)
  end

  def halfway
    @from_date.at_beginning_of_month + 14.days
  end

  def days_left_in_month
    @from_date.at_end_of_month.day - @from_date.day
  end

  def total_days_in_month
    @from_date.to_date.all_month.count
  end
end
