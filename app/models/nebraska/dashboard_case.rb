# frozen_string_literal: true

module Nebraska
  # A case for display in the Nebraska Dashboard
  # rubocop:disable Metrics/ClassLength
  class DashboardCase
    attr_reader :approval,
                :child_approval,
                :approval_attendances,
                :child,
                :filter_date,
                :service_days_this_approval,
                :service_days_this_month,
                :scheduled_days,
                :attended_days,
                :reimbursable_absence_days,
                :estimated_days

    def initialize(child:, filter_date:)
      @approval = @child_approval&.approval
      @approval_attendances = service_days_this_approval&.non_absences
      @attended_days = attended_service_days
      @child = child
      @child_approval = child&.active_child_approval(filter_date)
      @estimated_days = estimated_service_days
      @filter_date = filter_date
      @reimbursable_absence_days = reimbursable_absence_service_days
      @scheduled_days = scheduled_service_days
      @service_days_this_approval = child_approval&.service_days
      @service_days_this_month = child&.service_days&.for_month(filter_date)
    end

    def scheduled_service_days
      nil
      # TODO: this is the query killer
      # start_date = filter_date.in_time_zone(child.timezone).at_beginning_of_month.to_date
      # end_date = filter_date.in_time_zone(child.timezone).at_end_of_month.to_date
      # days = []
      # (start_date..end_date).map do |date|
      #   next unless child.schedules.active_on(date).collect(&:weekday).include?(date.wday)

      #   days << Nebraska::CalculatedServiceDay.new(service_day: ServiceDay.new(date: date, child: child))
      # end
      # days
    end

    def attended_service_days
      return unless service_days_this_month

      days = []
      service_days_this_month.includes(:attendances).non_absences.map do |service_day|
        days << Nebraska::CalculatedServiceDay.new(service_day: service_day)
      end
      days
    end

    def estimated_service_days
      return unless scheduled_days

      scheduled_days.select do |service_day|
        attended_days.collect { |day| day&.date }.exclude?(service_day.date)
      end
    end

    def reimbursable_absence_service_days
      return unless service_days_this_month

      days = []
      service_days_this_month.includes(:attendances).covid_absences.map do |service_day|
        days << Nebraska::CalculatedServiceDay.new(service_day: service_day)
      end
      service_days_this_month.includes(:attendances).standard_absences.order(total_time_in_care: :desc).take(5).map do |service_day|
        days << Nebraska::CalculatedServiceDay.new(service_day: service_day)
      end
      days
    end

    def attendance_risk
      Nebraska::Monthly::AttendanceRiskCalculator.new(
        child: child,
        child_approval: child_approval,
        filter_date: filter_date,
        scheduled_revenue: scheduled_revenue,
        estimated_revenue: estimated_revenue
      ).call
    end

    def absences
      return 0 unless service_days_this_month

      service_days_this_month.absences.length
    end

    def case_number
      child_approval&.case_number
    end

    def family_fee
      return 0 unless child == approval&.child_with_most_scheduled_hours(filter_date)

      child.active_nebraska_approval_amount(filter_date)&.family_fee || 0.00
    end

    def earned_revenue
      [
        (attended_days&.sum(&:earned_revenue) || 0) +
          (reimbursable_absence_days&.sum(&:earned_revenue) || 0) -
          family_fee,
        0.0
      ].max
    end

    def estimated_revenue
      [
        (estimated_days&.sum(&:earned_revenue) || 0) +
          (attended_days&.sum(&:earned_revenue) || 0) +
          (reimbursable_absence_days&.sum(&:earned_revenue) || 0) -
          family_fee,
        0.0
      ].max.to_f.round(2)
    end

    def scheduled_revenue
      [
        (scheduled_days&.sum(&:earned_revenue) || 0) +
          family_fee,
        0.0
      ].max.to_f.round(2)
    end

    def full_days
      # TODO: this adds to the query
      # return 0 unless service_days_this_month

      # service_days_this_month.non_absences.reduce(0) do |sum, service_day|
      #   sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      # end
    end

    def hours
      # TODO: this adds to the query
      # return 0 unless service_days_this_month

      # service_days_this_month.non_absences.reduce(0) do |sum, service_day|
      #   sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      # end
    end

    # TODO: anything called 'full days' should be made consistent - daily/days
    def full_days_remaining
      0
      # return 0 unless full_days_authorized

      # [full_days_authorized - attended_approval_days - absent_approval_days, 0].max
    end

    def hours_remaining
      0
      # return 0 unless hours_authorized

      # [hours_authorized - attended_approval_hours - absent_approval_hours, 0.0].max
    end

    def full_days_authorized
      child_approval&.full_days || 0
    end

    def hours_authorized
      child_approval&.hours || 0
    end

    # TODO: rename attended_weekly_hours
    def hours_attended
      0
      # TODO: this adds to the query
      # return 0 unless service_days_this_month

      # authorized_weekly_hours = child_approval&.authorized_weekly_hours
      # attended_weekly_hours = Nebraska::Weekly::AttendedHoursCalculator.new(
      #   service_days: service_days_this_month,
      #   filter_date: filter_date
      # ).call
      # "#{attended_weekly_hours&.positive? ? attended_weekly_hours : 0.0} of #{authorized_weekly_hours}"
    end

    def approval_effective_on
      child_approval&.effective_on
    end

    def approval_expires_on
      child_approval&.expires_on
    end

    private

    def approval_hourly_service_days
      # approval_attendances.ne_hourly.or(
      #   approval_attendances.ne_daily_plus_hourly
      # ).or(
      #   approval_attendances.ne_daily_plus_hourly_max
      # )
    end

    def attended_approval_hours
      # approval_hourly_service_days.reduce(0) do |sum, service_day|
      #   sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      # end
    end

    def approval_daily_service_days
      # approval_attendances.ne_daily.or(
      #   approval_attendances.ne_daily_plus_hourly
      # ).or(
      #   approval_attendances.ne_daily_plus_hourly_max
      # )
    end

    def attended_approval_days
      # approval_daily_service_days.reduce(0) do |sum, service_day|
      #   sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      # end
    end

    def approval_absences
      # return if service_days_this_approval.standard_absences.blank?

      # ServiceDay.where(id: approval_absence_ids)
    end

    def approval_absence_ids
      # (child_approval.effective_on.month..filter_date.month).map.with_index do |_month, index|
      #   approval_standard_absences(index)
      # end.flatten
    end

    def approval_standard_absences(index)
      # service_days_this_approval
      #   .standard_absences
      #   .for_month(child_approval.effective_on + index.months)
      #   .limit(5)
      #   .pluck(:id)
    end

    def approval_hourly_absences
      # return if approval_absences.blank?

      # approval_absences.ne_hourly
      #                  .or(approval_absences.ne_daily_plus_hourly)
      #                  .or(approval_absences.ne_daily_plus_hourly_max)
    end

    def absent_approval_hours
      # return 0.0 if approval_hourly_absences.blank?

      # approval_hourly_absences.reduce(0) do |sum, service_day|
      #   sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      # end
    end

    def approval_daily_absences
      # return if approval_absences.blank?

      # approval_absences.ne_daily
      #                  .or(approval_absences.ne_daily_plus_hourly)
      #                  .or(approval_absences.ne_daily_plus_hourly_max)
    end

    def absent_approval_days
      # return 0 if approval_daily_absences.blank?

      # approval_daily_absences.reduce(0) do |sum, service_day|
      #   sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      # end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
