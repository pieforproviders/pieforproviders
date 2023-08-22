# frozen_string_literal: true

module Nebraska
  # A case for display in the Nebraska Dashboard
  # rubocop:disable Metrics/ClassLength
  class DashboardCase
    attr_reader :absent_days,
                :attended_days,
                :business,
                :child,
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
      @reimbursable_month_absent_days = reimbursable_absent_service_days
    end

    def attendance_risk
      Appsignal.instrument_sql(
        'dashboard_case.attendance_risk'
      ) do
        Nebraska::Monthly::AttendanceRiskCalculator.new(
          timezone: child.timezone,
          filter_date: filter_date,
          family_fee: family_fee,
          scheduled_revenue: scheduled_revenue,
          estimated_revenue: estimated_revenue
        ).call
      end
    end

    def absences
      Appsignal.instrument_sql(
        'dashboard_case.absences'
      ) do
        @absences ||= absent_days
          &.for_month(filter_date)
          &.size || 0
      end
    end

    def absences_dates
      Appsignal.instrument_sql(
        'dashboard_case.absences_dates'
      ) do
        @absences_dates ||= absent_days
          &.for_month(filter_date)
      end
    end

    def case_number
      Appsignal.instrument_sql(
        'dashboard_case.case_number'
      ) do
        child_approval&.case_number
      end
    end

    # TODO: calculate this on the child_approval level and store it
    def family_fee
      Appsignal.instrument_sql(
        'dashboard_case.family_fee'
      ) do
        if approval.children.length != 1 && approval.child_with_most_scheduled_hours(date: filter_date) != child
          return Money.from_amount(0)
        end

        @family_fee ||= active_nebraska_approval_amount&.family_fee || Money.from_amount(0)
      end
    end

    def earned_revenue
      Appsignal.instrument_sql(
        'dashboard_case.earned_revenue'
      ) do
        @earned_revenue ||= [
          attended_month_days_revenue +
            reimbursable_month_absent_days_revenue -
            family_fee,
          Money.from_amount(0)
        ].max
      end
    end

    def estimated_revenue
      Appsignal.instrument_sql(
        'dashboard_case.estimated_revenue'
      ) do
        @estimated_revenue ||= [
          estimated_month_days_revenue +
            attended_month_days_revenue +
            reimbursable_month_absent_days_revenue -
            family_fee,
          Money.from_amount(0)
        ].max
      end
    end

    def scheduled_revenue
      Appsignal.instrument_sql(
        'dashboard_case.scheduled_revenue'
      ) do
        @scheduled_revenue ||= [
          scheduled_month_days_revenue -
            family_fee,
          Money.from_amount(0)
        ].max
      end
    end

    def full_days
      Appsignal.instrument_sql(
        'dashboard_case.full_days'
      ) do
        return 0 unless attendances_this_month

        @full_days ||= attendances_this_month.reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::DaysDurationCalculator.new(
            total_time_in_care: service_day.total_time_in_care,
            filter_date: filter_date
          ).call
        end
      end
    end

    def part_days
      Appsignal.instrument_sql(
        'dashboard_case.part_days'
      ) do
        return 0 unless attendances_this_month

        @part_days = 0
        attendances_this_month.each do |service_day|
          @part_days += 1 if service_day.part_time == 1
        end
        @part_days
      end
    end

    def total_part_days
      Appsignal.instrument_sql('dashboard_case.total_part_days') do
        child.child_approvals.first.part_days
      end
    end

    def remaining_part_days
      Appsignal.instrument_sql(
        'dashboard_case.remaining_part_days'
      ) do
        total_part_days.present? && part_days.present? ? total_part_days - part_days : nil
      end
    end

    def hours
      Appsignal.instrument_sql(
        'dashboard_case.hours'
      ) do
        return 0 unless attendances_this_month

        @hours ||= attendances_this_month.reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::HoursDurationCalculator.new(
            total_time_in_care: service_day.total_time_in_care
          ).call
        end
      end
    end

    # TODO: anything called 'full days' should be made consistent - daily/days
    def full_days_remaining
      Appsignal.instrument_sql(
        'dashboard_case.full_days_remaining'
      ) do
        return 0 unless attended_days || reimbursable_approval_absent_days

        @full_days_remaining ||= days = approval_days_to_count_for_duration_limits
                                        .reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::DaysDurationCalculator.new(
            total_time_in_care: service_day.total_time_in_care
          ).call
        end

        [full_days_authorized - days, 0].max
      end
    end

    def hours_remaining
      Appsignal.instrument_sql(
        'dashboard_case.hours_remaining'
      ) do
        return 0 unless attended_days || reimbursable_approval_absent_days

        @hours_remaining ||= hours = approval_days_to_count_for_duration_limits
                                     .reduce(0) do |sum, service_day|
          sum + Nebraska::Daily::HoursDurationCalculator.new(
            total_time_in_care: service_day.total_time_in_care
          ).call
        end

        [hours_authorized - hours, 0].max
      end
    end

    def full_days_authorized
      Appsignal.instrument_sql(
        'dashboard_case.full_days_authorized'
      ) do
        @full_days_authorized ||= child_approval&.full_days || 0
      end
    end

    def hours_authorized
      Appsignal.instrument_sql(
        'dashboard_case.hours_authorized'
      ) do
        @hours_authorized ||= child_approval&.hours || 0
      end
    end

    def attended_weekly_hours
      Appsignal.instrument_sql(
        'dashboard_case.attended_weekly_hours'
      ) do
        authorized_weekly_hours = child_approval&.authorized_weekly_hours
        authorized_weekly_hours.to_i.to_s
      end
    end

    def approval_effective_on
      Appsignal.instrument_sql(
        'dashboard_case.approval_effective_on'
      ) do
        @approval_effective_on ||= child_approval&.effective_on
      end
    end

    def approval_expires_on
      Appsignal.instrument_sql(
        'dashboard_case.approval_expires_on'
      ) do
        @approval_expires_on ||= child_approval&.expires_on
      end
    end

    private

    def child_approvals
      Appsignal.instrument_sql(
        'dashboard_case.child_approvals'
      ) do
        @child_approvals ||= child&.child_approvals&.with_approval
      end
    end

    def approval
      Appsignal.instrument_sql(
        'dashboard_case.approval'
      ) do
        @approval ||= child&.approvals&.active_on(filter_date)&.first
      end
    end

    def child_approval
      Appsignal.instrument_sql(
        'dashboard_case.child_approval'
      ) do
        @child_approval ||= approval&.child_approvals&.find_by(child: child)
      end
    end

    def active_nebraska_approval_amount
      Appsignal.instrument_sql(
        'dashboard_case.active_nebraska_approval_amount',
        'selects the current active nebraska approval amount for this child and memoizes it'
      ) do
        @active_nebraska_approval_amount ||= child&.active_nebraska_approval_amount(filter_date)
      end
    end

    def absences_this_month
      Appsignal.instrument_sql(
        'dashboard_case.absences_this_month',
        'selects only the absences for this month and memoizes them'
      ) do
        @absences_this_month ||= absent_days&.select do |service_day|
          service_day.date.between?(filter_date.at_beginning_of_month, filter_date.at_end_of_month)
        end
      end
    end

    def attendances_this_month
      Appsignal.instrument_sql(
        'dashboard_case.attendances_this_month',
        'selects only the attendances for this month and memoizes them'
      ) do
        @attendances_this_month ||= attended_days&.select do |service_day|
          service_day.date.between?(filter_date.at_beginning_of_month, filter_date.at_end_of_month)
        end
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
        @scheduled_month_days_revenue ||= scheduled_month_days&.map(&:earned_revenue)&.sum || 0
      end
    end

    def estimated_month_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.estimated_month_days_revenue',
        'map & sum earned revenue of estimated month days'
      ) do
        @estimated_month_days_revenue ||= estimated_month_days&.map(&:earned_revenue)&.sum || 0
      end
    end

    def attended_month_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.attended_month_days_revenue',
        'map & sum earned revenue of attended month days'
      ) do
        @attended_month_days_revenue ||= attendances_this_month&.map(&:earned_revenue)&.sum || 0
      end
    end

    def reimbursable_month_absent_days_revenue
      Appsignal.instrument_sql(
        'dashboard_case.reimbursable_month_absent_days_revenue',
        'map & sum earned revenue of reimbursable month absent days'
      ) do
        @reimbursable_month_absent_days_revenue ||=
          reimbursable_month_absent_days&.map { |item| check_absent_days_earned_revenue(item.earned_revenue) }&.sum || 0
      end
    end

    def check_absent_days_earned_revenue(revenue)
      if revenue.nil?
        Money.from_amount(0)
      else
        revenue
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
        @month_schedule_start ||= filter_date.in_time_zone(child.timezone).at_beginning_of_month.to_date
      end
    end

    def month_schedule_end
      Appsignal.instrument_sql(
        'dashboard_case.month_schedule_end',
        'gets last of the month of the filter_date'
      ) do
        @month_schedule_end ||= filter_date.in_time_zone(child.timezone).at_end_of_month.to_date
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
        @attended_and_absent_dates ||= [
          attendances_this_month,
          absences_this_month
        ].compact.reduce([], :|).collect { |attended_day| attended_day.date.to_date }
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
        @non_covid_approval_absences ||= reimbursable_approval_absent_days.reject do |absence|
          absence.absence_type == 'covid_absence'
        end
      end
    end

    def approval_days_to_count_for_duration_limits
      Appsignal.instrument_sql(
        'dashboard_case.approval_days_to_count_for_duration_limits',
        'reduce out nils from attendances for the approval'
      ) do
        @approval_days_to_count_for_duration_limits ||= [
          attended_days,
          non_covid_approval_absences
        ].compact.reduce([], :|)
      end
    end

    def absences_for_month(month:)
      Appsignal.instrument_sql(
        'dashboard_case.absences_for_month',
        'reduce out nils from attendances for the approval'
      ) do
        absent_days.select do |service_day|
          service_day.date.between?(month.at_beginning_of_month, month.at_end_of_month)
        end
      end
    end

    def split_absences_by_type(absences:)
      Appsignal.instrument_sql(
        'dashboard_case.split_absences_by_type',
        'create two arrays of absences by type'
      ) do
        absences.partition do |service_day|
          service_day.absence_type == 'covid_absence'
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
