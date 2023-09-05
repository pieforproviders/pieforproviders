# frozen_string_literal: true

# Service to calculate a family's attendance rate
class IllinoisAttendanceRateCalculator
  def initialize(child, filter_date, eligible_days: nil, attended_days: nil)
    @child = child
    @filter_date = filter_date
    @business = child&.businesses&.find_by(active: true)
    @eligible_days = eligible_days
    @attended_days = attended_days
  end

  def call
    return (@attended_days.to_f / @eligible_days).round(3) if @eligible_days.present? && @attended_days.present?

    return 0 unless active_approval.presence && family_days_approved.positive?

    (family_days_attended.to_f / family_days_approved).round(3)
  end

  def family_days_approved
    days = 0
    active_approval.children.each { |child| days += sum_eligible_days(child) }

    days
  end

  def family_days_attended
    days = 0
    active_approval.children.each { |child| days += sum_attendances(child) }

    days
  end

  private

  def active_approval
    @child.approvals.active_on(@filter_date).first
  end

  def sum_eligible_days(child)
    eligible_days = []

    if full_time_attendance_presence?(child)
      eligible_days << Illinois::EligibleDaysCalculator.new(date: @filter_date, child: child).call
    end
    if part_time_attendance_presence?(child)
      eligible_days << Illinois::EligibleDaysCalculator.new(date: @filter_date, child: child, full_time: false).call
    end

    eligible_days.compact.sum
  end

  def sum_attendances(child)
    attendances = child.attendances.for_month(@filter_date)

    return 0 unless attendances

    [
      attendances.illinois_part_days.count,
      attendances.illinois_full_days.count,
      attendances.illinois_full_plus_part_days.count * 2,
      attendances.illinois_full_plus_full_days.count * 2
    ].sum
  end

  def does_not_meet_approval_requirements?
    @approval_amount.nil? || missing_approved_info?
  end

  def missing_approved_info?
    @approval_amount.part_days_approved_per_week.nil? || @approval_amount.full_days_approved_per_week.nil?
  end

  def full_time_attendance_presence?(child)
    child.service_days.for_month(@filter_date).full_day.any?
  end

  def part_time_attendance_presence?(child)
    child.service_days.for_month(@filter_date).part_day.any?
  end
end
