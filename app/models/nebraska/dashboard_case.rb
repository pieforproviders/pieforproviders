# frozen_string_literal: true

module Nebraska
  # A case for display in the Nebraska Dashboard
  # rubocop:disable Metrics/ClassLength
  class DashboardCase
    attr_reader :approval,
                :business,
                :child,
                :child_approvals,
                :child_approval,
                :filter_date,
                :reimbursable_month_absent_days,
                :schedules,
                :service_days

    def initialize(child:, filter_date:)
      @child = child
      @filter_date = filter_date
      @business = child.business
      @schedules = child&.schedules
      @child_approvals = child&.child_approvals
      @child_approval = child_approval_for_case
      @approval = child_approval&.approval
      @service_days = child&.service_days&.with_attendances
      @reimbursable_month_absent_days = reimbursable_absent_service_days
    end

    def attendance_risk
      Nebraska::Monthly::AttendanceRiskCalculator.new(
        child: child,
        filter_date: filter_date,
        scheduled_revenue: scheduled_revenue,
        estimated_revenue: estimated_revenue
      ).call
    end

    def absences
      return 0 unless absences_this_month

      absences_this_month.length
    end

    def case_number
      child_approval&.case_number
    end

    def family_fee
      return 0 if approval.children.length != 1 && approval.child_with_most_scheduled_hours(date: filter_date) != child

      child.active_nebraska_approval_amount(filter_date)&.family_fee || 0.00
    end

    def earned_revenue
      [
        attended_month_days_revenue +
          reimbursable_month_absent_days_revenue -
          family_fee,
        0.0
      ].max
    end

    def estimated_revenue
      [
        estimated_month_days_revenue +
          attended_month_days_revenue +
          reimbursable_month_absent_days_revenue -
          family_fee,
        0.0
      ].max.to_f.round(2)
    end

    def scheduled_revenue
      [
        scheduled_month_days_revenue -
          family_fee,
        0.0
      ].max.to_f.round(2)
    end

    def full_days
      return 0 unless attended_month_days

      attended_month_days.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    def hours
      return 0 unless attended_month_days

      attended_month_days.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end
    end

    # TODO: anything called 'full days' should be made consistent - daily/days
    def full_days_remaining
      return 0 unless attended_approval_days || reimbursable_approval_absent_days

      days = approval_days_to_count_for_duration_limits.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end

      [full_days_authorized - days, 0].max
    end

    def hours_remaining
      return 0 unless attended_approval_days || reimbursable_approval_absent_days

      hours = approval_days_to_count_for_duration_limits.reduce(0) do |sum, service_day|
        sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
      end

      [hours_authorized - hours, 0].max
    end

    def full_days_authorized
      child_approval&.full_days || 0
    end

    def hours_authorized
      child_approval&.hours || 0
    end

    def attended_weekly_hours
      return 0 unless service_days_this_month

      authorized_weekly_hours = child_approval&.authorized_weekly_hours
      attended_hours = Nebraska::Weekly::AttendedHoursCalculator.new(
        service_days: service_days_this_month,
        filter_date: filter_date,
        child_approvals: child_approvals,
        rates: rates
      ).call
      "#{attended_hours&.positive? ? attended_hours : 0.0} of #{authorized_weekly_hours}"
    end

    def approval_effective_on
      child_approval&.effective_on
    end

    def approval_expires_on
      child_approval&.expires_on
    end

    private

    def active_nebraska_approval_amount
      child.nebraska_approval_amounts.select do |nebraska_approval_amount|
        nebraska_approval_amount.effective_on <= filter_date &&
          (nebraska_approval_amount.expires_on.nil? || nebraska_approval_amount.expires_on > filter_date)
      end&.first
    end

    def child_approval_for_case
      child_approvals.includes(:approval).select do |child_approval|
        child_approval.effective_on <= filter_date &&
          (child_approval.expires_on.nil? || child_approval.expires_on > filter_date)
      end.first
    end

    def service_days_this_child_approval
      @service_days_this_child_approval ||= service_days.select do |service_day|
        service_day.attendances.any? do |attendance|
          attendance.child_approval == child_approval
        end
      end
    end

    def service_days_this_month
      @service_days_this_month ||= service_days.select do |service_day|
        service_day.date.between?(filter_date.at_beginning_of_month, filter_date.at_end_of_month)
      end
    end

    def absences_this_month
      @absences_this_month ||= service_days_this_month.select do |service_day|
        service_day.attendances.any? do |attendance|
          attendance.absence.present?
        end
      end
    end

    def attendances_this_month
      @attendances_this_month ||= service_days_this_month.select do |service_day|
        service_day.attendances.all? do |attendance|
          attendance.absence.nil?
        end
      end
    end

    def rates
      @rates ||= NebraskaRate.for_case(
        filter_date,
        child_approval&.enrolled_in_school || false,
        child.age_in_months(filter_date),
        business
      )
    end

    def scheduled_month_days_revenue
      scheduled_month_days&.map(&:earned_revenue)&.sum || 0
    end

    def estimated_month_days_revenue
      estimated_month_days&.map(&:earned_revenue)&.sum || 0
    end

    def attended_month_days_revenue
      attended_month_days&.map(&:earned_revenue)&.sum || 0
    end

    def reimbursable_month_absent_days_revenue
      reimbursable_month_absent_days&.map(&:earned_revenue)&.sum || 0
    end

    def scheduled_month_days
      days = []
      (month_schedule_start..month_schedule_end).map do |date|
        schedule = schedule_for_day(date)
        next unless schedule

        days << make_calculated_service_day(
          service_day: ServiceDay.new(
            date: date,
            child: child,
            schedule: schedule,
            total_time_in_care: schedule&.duration || 8.hours
          )
        )
      end
      @scheduled_month_days ||= days
    end

    def schedule_for_day(date)
      schedules.select do |schedule|
        schedule.weekday == date.wday &&
          schedule.effective_on <= date &&
          (schedule.expires_on.nil? || schedule.expires_on > date)
      end.first
    end

    def month_schedule_start
      filter_date.in_time_zone(child.timezone).at_beginning_of_month.to_date
    end

    def month_schedule_end
      filter_date.in_time_zone(child.timezone).at_end_of_month.to_date
    end

    def attended_month_days
      attendances = attendances_this_month

      return unless attendances

      @attended_month_days ||= attendances.map do |service_day|
        make_calculated_service_day(service_day: service_day)
      end
    end

    def absent_month_days
      absences = absences_this_month

      return unless absences

      @absent_month_days ||= absences.map do |service_day|
        make_calculated_service_day(service_day: service_day)
      end
    end

    def estimated_month_days
      return unless scheduled_month_days

      @estimated_month_days ||= scheduled_month_days.select do |scheduled_day|
        date = scheduled_day.service_day.date.to_date
        date >= filter_date.to_date && attended_and_absent_dates.exclude?(date)
      end
    end

    def attended_and_absent_dates
      [attended_month_days, absent_month_days].compact.reduce([], :|).collect do |attended_day|
        attended_day.service_day.date.to_date
      end
    end

    def reimbursable_absent_service_days(month: nil)
      absences = month ? absences_for_month(month: month) : absences_this_month

      return if absences.blank?

      covid_absences, standard_absences = split_absences_by_type(absences: absences)
      absences_to_reimburse = [
        covid_absences,
        standard_absences.sort_by(&:total_time_in_care).reverse!.take(5)
      ].compact.reduce([], :|)

      absences_to_reimburse.map! do |service_day|
        make_calculated_service_day(service_day: service_day)
      end
    end

    def non_covid_approval_absences
      reimbursable_approval_absent_days.reject do |absence|
        absence.service_day.attendances.any? do |attendance|
          attendance.absence == 'covid_absence'
        end
      end
    end

    def approval_days_to_count_for_duration_limits
      [attended_approval_days, non_covid_approval_absences].compact.reduce([], :|)
    end

    def absences_for_month(month:)
      service_days_this_child_approval.select do |service_day|
        service_day.date.between?(month.at_beginning_of_month, month.at_end_of_month) &&
          service_day.attendances.any? { |attendance| attendance.absence.present? }
      end
    end

    def split_absences_by_type(absences:)
      absences.partition do |service_day|
        service_day.attendances.any? do |attendance|
          attendance.absence == 'covid_absence'
        end
      end
    end

    def attended_approval_days
      return unless service_days_this_child_approval

      days = service_days_this_child_approval.select do |service_day|
        service_day.attendances.all? do |attendance|
          attendance.absence.nil?
        end
      end
      @attended_approval_days ||= days.map! do |service_day|
        make_calculated_service_day(service_day: service_day)
      end
    end

    def reimbursable_approval_absent_days
      return unless service_days_this_child_approval

      days = []
      start_date = approval.effective_on.to_date
      end_date = filter_date
      date = start_date

      while date <= end_date.at_end_of_month
        days = [days, reimbursable_absent_service_days(month: date)].compact.reduce([], :|)
        date += 1.month
      end
      @reimbursable_approval_absent_days ||= days
    end

    def make_calculated_service_day(service_day:)
      Nebraska::CalculatedServiceDay.new(
        service_day: service_day,
        child_approvals: child_approvals,
        rates: rates
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
