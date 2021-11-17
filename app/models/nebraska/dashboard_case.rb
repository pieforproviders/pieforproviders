# frozen_string_literal: true

module Nebraska
  # A case for display in the Nebraska Dashboard
  class DashboardCase
    attr_reader :child, :filter_date

    def initialize(child:, filter_date:)
      @child = child
      @filter_date = filter_date
    end

    def attendance_risk
      Nebraska::Monthly::AttendanceRiskCalculator.new(child: child, filter_date: filter_date).call
    end

    def absences
      child.service_days.for_month(filter_date).absences.length
    end

    def case_number
      child.approvals.active_on_date(filter_date).first&.case_number
    end

    def family_fee
      return 0 unless child == child.active_approval(filter_date).child_with_most_scheduled_hours(filter_date)

      child.active_nebraska_approval_amount(filter_date)&.family_fee || 0.00
    end

    def earned_revenue
      # TODO: I don't like that we're doing this here, in the dashboard case, rather than in the API response
      # but it's the simplest way to make sure that the family fee is only subtracted
      # one time from each of earned_revenue and estimated_revenue - we should add a class to calculate w/ fam fee
      [
        Nebraska::Monthly::EarnedRevenueCalculator.new(child: child, filter_date: filter_date).call - family_fee,
        0.0
      ].max
    end

    def estimated_revenue
      # TODO: I don't like that we're doing this here, in the dashboard case, rather than in the API response
      # but it's the simplest way to make sure that the family fee is only subtracted
      # one time from each of earned_revenue and estimated_revenue - we should add a class to calculate w/ fam fee
      [
        Nebraska::Monthly::EstimatedRevenueCalculator.new(child: child, filter_date: filter_date).call - family_fee,
        0.0
      ].max
    end

    def full_days
      child.service_days.non_absences.for_month(filter_date).reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    def hours
      child.service_days.non_absences.for_month(filter_date).reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    # TODO: anything called 'full days' should be made consistent - daily/days
    def full_days_remaining
      return 0 unless full_days_authorized

      [full_days_authorized - attended_approval_days - absent_approval_days, 0].max
    end

    def hours_remaining
      return 0 unless hours_authorized

      [hours_authorized - attended_approval_hours - absent_approval_hours, 0.0].max
    end

    def full_days_authorized
      child.active_child_approval(filter_date)&.full_days
    end

    def hours_authorized
      child.active_child_approval(filter_date)&.hours
    end

    # TODO: rename attended_weekly_hours
    def hours_attended
      authorized_weekly_hours = child.active_child_approval(filter_date).authorized_weekly_hours
      attended_weekly_hours = Nebraska::Weekly::AttendedHoursCalculator.new(child: child,
                                                                            filter_date: filter_date).call
      "#{attended_weekly_hours&.positive? ? attended_weekly_hours : 0.0} of #{authorized_weekly_hours}"
    end

    private

    def approval_attendances
      child.active_child_approval(filter_date).service_days.non_absences
    end

    def approval_hourly_service_days
      approval_attendances.hourly
                          .or(approval_attendances.daily_plus_hourly)
                          .or(approval_attendances.daily_plus_hourly_max)
    end

    def attended_approval_hours
      approval_hourly_service_days.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    def approval_daily_service_days
      approval_attendances.daily
                          .or(approval_attendances.daily_plus_hourly)
                          .or(approval_attendances.daily_plus_hourly_max)
    end

    def attended_approval_days
      approval_daily_service_days.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    def child_approval
      child.active_child_approval(filter_date)
    end

    def approval_absences
      return if child_approval.service_days.standard_absences.blank?

      ServiceDay.where(id: approval_absence_ids)
    end

    def approval_absence_ids
      (child_approval.effective_on.month..filter_date.month).map.with_index do |_month, index|
        approval_standard_absences(index)
      end.flatten
    end

    def approval_standard_absences(index)
      child_approval
        .service_days
        .standard_absences
        .for_month(child_approval.effective_on + index.months)
        .limit(5)
        .pluck(:id)
    end

    def approval_hourly_absences
      return if approval_absences.blank?

      approval_absences.hourly.or(approval_absences.daily_plus_hourly).or(approval_absences.daily_plus_hourly_max)
    end

    def absent_approval_hours
      return 0.0 if approval_hourly_absences.blank?

      approval_hourly_absences.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    def approval_daily_absences
      return if approval_absences.blank?

      approval_absences.daily.or(approval_absences.daily_plus_hourly).or(approval_absences.daily_plus_hourly_max)
    end

    def absent_approval_days
      return 0 if approval_daily_absences.blank?

      approval_daily_absences.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end
  end
end
