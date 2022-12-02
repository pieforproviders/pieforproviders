# frozen_string_literal: true

# Service to calculate a family's attendance rate
class IllinoisAttendanceRateCalculator
  def initialize(child, filter_date)
    @child = child
    @filter_date = filter_date
  end

  def call
    return 0 unless active_approval.presence && family_days_approved.positive?

    (family_days_attended.to_f / family_days_approved).round(3)
  end

  def family_days_approved
    days = 0
    active_approval.children.each { |child| days += sum_approvals(child) }
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

  def sum_approvals(child)
    @approval_amount = child.illinois_approval_amounts.for_month(@filter_date).first
    return 0 if does_not_meet_approval_requirements?

    weeks_in_month = DateService.weeks_in_month(@filter_date)

    [
      @approval_amount.part_days_approved_per_week * weeks_in_month,
      @approval_amount.full_days_approved_per_week * weeks_in_month
    ].sum
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
end
