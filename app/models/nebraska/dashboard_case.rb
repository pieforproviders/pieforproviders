# frozen_string_literal: true

module Nebraska
  # A case for display in the Nebraska Dashboard
  # rubocop:disable Metrics/ClassLength
  class DashboardCase
    attr_reader :absent_days,
                :active_nebraska_approval_amount,
                :approval,
                :attended_days,
                :business,
                :child,
                :child_approvals,
                :child_approval,
                :filter_date,
                :reimbursable_month_absent_days,
                :schedules

    def initialize(child:, filter_date:, attended_days:, absent_days:)
      @child = child
      @filter_date = filter_date
      @attended_days = attended_days
      @absent_days = absent_days
      @business = child.business
      @schedules = child&.schedules
      @child_approvals = child&.child_approvals&.with_approval
      @approval = child&.approvals&.active_on(filter_date)&.first
      @child_approval = approval.child_approvals.find_by(child: child)
      @reimbursable_month_absent_days = reimbursable_absent_service_days
      @active_nebraska_approval_amount = child&.active_nebraska_approval_amount(filter_date)
    end

    def attendance_risk
      Appsignal.instrument_sql(
        'dashboard_case.attendance_risk'
      ) do
        Nebraska::Monthly::AttendanceRiskCalculator.new(
          child: child,
          filter_date: filter_date,
          scheduled_revenue: scheduled_revenue,
          estimated_revenue: estimated_revenue
        ).call
      end
    end

    def absences
      Appsignal.instrument_sql(
        'dashboard_case.absences'
      ) do
        return 0 unless absences_this_month

        absences_this_month.select do |service_day|
          service_day.attendances.none? { |attendance| attendance.absence == 'covid_absence' }
        end.length
      end
    end

    def case_number
      Appsignal.instrument_sql(
        'dashboard_case.case_number'
      ) do
        child_approval&.case_number
      end
    end

    def family_fee
      Appsignal.instrument_sql(
        'dashboard_case.family_fee'
      ) do
        if approval.children.length != 1 && approval.child_with_most_scheduled_hours(date: filter_date) != child
          return 0
        end

        active_nebraska_approval_amount&.family_fee || 0
      end
    end

    def earned_revenue
      Appsignal.instrument_sql(
        'dashboard_case.earned_revenue'
      ) do
        [
          attended_month_days_revenue +
            reimbursable_month_absent_days_revenue -
            family_fee,
          0.0
        ].max
      end
    end

    def estimated_revenue
      Appsignal.instrument_sql(
        'dashboard_case.estimated_revenue'
      ) do
        [
          estimated_month_days_revenue +
            attended_month_days_revenue +
            reimbursable_month_absent_days_revenue -
            family_fee,
          0.0
        ].max
      end
    end

    def scheduled_revenue
      Appsignal.instrument_sql(
        'dashboard_case.scheduled_revenue'
      ) do
        [
          scheduled_month_days_revenue -
            family_fee,
          0.0
        ].max.to_f.round(2)
      end
    end

    def full_days
      Appsignal.instrument_sql(
        'dashboard_case.full_days'
      ) do
        return 0 unless attendances_this_month

        attendances_this_month.reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
        end
      end
    end

    def hours
      Appsignal.instrument_sql(
        'dashboard_case.hours'
      ) do
        return 0 unless attendances_this_month

        attendances_this_month.reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
        end
      end
    end

    # TODO: anything called 'full days' should be made consistent - daily/days
    def full_days_remaining
      Appsignal.instrument_sql(
        'dashboard_case.full_days_remaining'
      ) do
        return 0 unless attended_days || reimbursable_approval_absent_days

        days = approval_days_to_count_for_duration_limits.reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
        end

        [full_days_authorized - days, 0].max
      end
    end

    def hours_remaining
      Appsignal.instrument_sql(
        'dashboard_case.hours_remaining'
      ) do
        return 0 unless attended_days || reimbursable_approval_absent_days

        hours = approval_days_to_count_for_duration_limits.reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: service_day.total_time_in_care).call
        end

        [hours_authorized - hours, 0].max
      end
    end

    def full_days_authorized
      Appsignal.instrument_sql(
        'dashboard_case.full_days_authorized'
      ) do
        child_approval&.full_days || 0
      end
    end

    def hours_authorized
      Appsignal.instrument_sql(
        'dashboard_case.hours_authorized'
      ) do
        child_approval&.hours || 0
      end
    end

    def attended_weekly_hours
      Appsignal.instrument_sql(
        'dashboard_case.attended_weekly_hours'
      ) do
        authorized_weekly_hours = child_approval&.authorized_weekly_hours
        return "0.0 of #{authorized_weekly_hours}" unless attendances_this_month || reimbursable_month_absent_days

        attended_hours = Nebraska::Weekly::AttendedHoursCalculator.new(
          attendances: attendances_this_month,
          absences: reimbursable_month_absent_days,
          filter_date: filter_date
        ).call
        "#{attended_hours&.positive? ? attended_hours : 0.0} of #{authorized_weekly_hours}"
      end
    end

    def approval_effective_on
      Appsignal.instrument_sql(
        'dashboard_case.approval_effective_on'
      ) do
        child_approval&.effective_on
      end
    end

    def approval_expires_on
      Appsignal.instrument_sql(
        'dashboard_case.approval_expires_on'
      ) do
        child_approval&.expires_on
      end
    end

    private

    def absences_this_month
      Appsignal.instrument_sql(
        'dashboard_case.absences_this_month',
        'selects only the absences for this month and memoizes them'
      ) do
        @absences_this_month ||= absent_days.where(date: filter_date.at_beginning_of_month..filter_date.at_end_of_month)
      end
    end

    def attendances_this_month
      Appsignal.instrument_sql(
        'dashboard_case.attendances_this_month',
        'selects only the attendances for this month and memoizes them'
      ) do
        @attendances_this_month ||= attended_days.where(date: filter_date.at_beginning_of_month..filter_date.at_end_of_month)
      end
    end

    def rates
      Appsignal.instrument_sql('dashboard_case.rates', 'queries rates for the case and memoizes them') do
        @rates ||= NebraskaRate.for_case(
          filter_date,
          child_approval&.enrolled_in_school || false,
          child.age_in_months(filter_date),
          business
        )
      end
    end

    def scheduled_month_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.scheduled_month_days_revenue',
        'map & sum earned revenue of scheduled month days'
      ) do
        scheduled_month_days&.map(&:earned_revenue)&.sum || 0
      end
    end

    def estimated_month_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.estimated_month_days_revenue',
        'map & sum earned revenue of estimated month days'
      ) do
        estimated_month_days&.map(&:earned_revenue)&.sum || 0
      end
    end

    def attended_month_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.attended_month_days_revenue',
        'map & sum earned revenue of attended month days'
      ) do
        # binding.pry if child.full_name == 'Jasveen Khirwar'
        attendances_this_month&.map(&:earned_revenue)&.sum || 0
      end
    end

    def reimbursable_month_absent_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.reimbursable_month_absent_days_revenue',
        'map & sum earned revenue of reimbursable month absent days'
      ) do
        reimbursable_month_absent_days&.map(&:earned_revenue)&.sum || 0
      end
    end

    # rubocop:disable Metrics/MethodLength
    def scheduled_month_days
      Appsignal.instrument_sql(
        'dashboard_case.scheduled_month_days',
        'makes and memoizes calculated service days for all scheduled days'
      ) do
        return @scheduled_month_days if @scheduled_month_days

        days = []
        # TODO: pluck the dates for the Mondays (weekday 1) this month
        # get the rates for that date
        # get the duration from the schedule
        # run it through earned revenue
        # don't instantiate a calculated service day
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
    end
    # rubocop:enable Metrics/MethodLength

    def schedule_for_day(date)
      Appsignal.instrument_sql(
        'dashboard_case.schedule_for_day',
        'selects from schedules to find the one for a specific date'
      ) do
        schedules.find do |schedule|
          schedule.weekday == date.wday &&
            schedule.effective_on <= date &&
            (schedule.expires_on.nil? || schedule.expires_on > date)
        end
      end
    end

    def month_schedule_start
      Appsignal.instrument_sql(
        'dashboard_case.month_schedule_start',
        'gets first of the month of the filter_date'
      ) do
        filter_date.in_time_zone(child.timezone).at_beginning_of_month.to_date
      end
    end

    def month_schedule_end
      Appsignal.instrument_sql(
        'dashboard_case.month_schedule_end',
        'gets last of the month of the filter_date'
      ) do
        filter_date.in_time_zone(child.timezone).at_end_of_month.to_date
      end
    end

    def estimated_month_days
      Appsignal.instrument_sql(
        'dashboard_case.estimated_month_days',
        'finds scheduled days still remaining after the date in this month and memoizes them'
      ) do
        return unless scheduled_month_days

        @estimated_month_days ||= scheduled_month_days.select do |scheduled_day|
          date = scheduled_day.service_day.date.to_date
          # TODO: this might be overkill - tbh I'm not super sure why I'm removing attended and absent days
          # from a select that's only looking for dates in the future, unless it's specifically trying to find
          # today and determine if it's been attended or marked absent yet - seems like I shouldn't have
          # to look through all the dates to do that though
          date >= filter_date.to_date && attended_and_absent_dates.exclude?(date)
        end
      end
    end

    def attended_and_absent_dates
      Appsignal.instrument_sql(
        'dashboard_case.attended_and_absent_dates',
        'gets attended and absent days to remove them from estimated days above'
      ) do
        [attendances_this_month, absences_this_month].compact.reduce([], :|).collect do |attended_day|
          attended_day.date.to_date
        end
      end
    end

    def reimbursable_absent_service_days(month: nil)
      Appsignal.instrument_sql(
        'dashboard_case.reimbursable_absent_service_days',
        'finds reimbursable absent days for given month; COVID are reimbursable w/o restriction, others capped at 5'
      ) do
        absences = month ? absences_for_month(month: month) : absences_this_month

        return if absences.blank?

        covid_absences, standard_absences = split_absences_by_type(absences: absences)
        [
          covid_absences,
          standard_absences.sort_by(&:total_time_in_care).reverse!.take(5)
        ].compact.reduce([], :|)
      end
    end

    def non_covid_approval_absences
      Appsignal.instrument_sql(
        'dashboard_case.non_covid_approval_absences',
        'finds reimbursable absent days that are COVID absence'
      ) do
        reimbursable_approval_absent_days.reject do |absence|
          absence.attendances.any? do |attendance|
            attendance.absence == 'covid_absence'
          end
        end
      end
    end

    def approval_days_to_count_for_duration_limits
      Appsignal.instrument_sql(
        'dashboard_case.approval_days_to_count_for_duration_limits',
        'reduce out nils from attendances for the approval'
      ) do
        [attended_days, non_covid_approval_absences].compact.reduce([], :|)
      end
    end

    def absences_for_month(month:)
      Appsignal.instrument_sql(
        'dashboard_case.absences_for_month',
        'reduce out nils from attendances for the approval'
      ) do
        absent_days.where(date: month.at_beginning_of_month..month.at_end_of_month)
      end
    end

    def split_absences_by_type(absences:)
      Appsignal.instrument_sql(
        'dashboard_case.split_absences_by_type',
        'create two arrays of absences by type'
      ) do
        absences.partition do |service_day|
          service_day.attendances.any? do |attendance|
            attendance.absence == 'covid_absence'
          end
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def reimbursable_approval_absent_days
      Appsignal.instrument_sql(
        'dashboard_case.reimbursable_approval_absent_days',
        'gets reimbursable absent days for the approval and memoizes them'
      ) do
        return unless absent_days

        days = []
        date = approval.effective_on.to_date

        while date <= filter_date.at_end_of_month
          days = [days, reimbursable_absent_service_days(month: date)].compact.reduce([], :|)
          date += 1.month
        end
        @reimbursable_approval_absent_days ||= days
      end
    end
    # rubocop:enable Metrics/MethodLength

    def make_calculated_service_day(service_day:)
      Appsignal.instrument_sql(
        'dashboard_case.make_calculated_service_day',
        'makes a new calculated service day'
      ) do
        Nebraska::CalculatedServiceDay.new(
          service_day: service_day,
          child_approvals: child_approvals,
          rates: rates
        )
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
