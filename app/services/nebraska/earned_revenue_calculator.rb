# frozen_string_literal: true

module Nebraska
  # Calculate a child's earned revenue for the month so far
  class EarnedRevenueCalculator
    attr_reader :child, :date

    def initialize(child, date = nil)
      @child = child
      @date = (date || Time.current).in_time_zone(@child.timezone)
    end

    def call
      calculate_earned_revenue
    end

    private

    def calculate_earned_revenue
      service_days_to_count.compact_blank.map do |service_day|
        (service_day.rates.hourly.first * service_day.units.hours) +
          (service_day.rates.daily.first * service_day.units.days)
      end
    end

    def service_days_this_month
      service_days = child.service_days.for_month(date)
      service_days.map do |service_day|
        rounded_duration = round_to_quarters(service_day.total_time_in_care)
        {
          absence: service_day.absence?,
          units: units(rounded_duration),
          rates: service_day.rates
        }
      end
    end

    def service_days_to_count
      absences_up_to_limit + hourly_up_to_limit + daily_up_to_limit
    end

    def absences
      service_days_this_month.select { |service_day| service_day[:absence] }
    end

    def hourly
      service_days_this_month.select { |service_day| service_day[:units][:hours].positive? }
    end

    def daily
      service_days_this_month.select { |service_day| service_day[:units][:days].positive? }
    end

    # TODO: question for Rodrigo maybe - is there any reasonable way to store data like this with an effective date
    # so that if the definition of a "full day" ever changes, we can have historical accuracy?
    def units(rounded_duration)
      if rounded_duration <= (5.hours + 45.minutes)
        { hours: rounded_duration.in_hours }
      elsif rounded_duration <= 10.hours
        { days: 1 }
      elsif rounded_duration <= 18.hours
        { days: 1, hours: (rounded_duration - 10.hours).in_hours }
      elsif rounded_duration > 18.hours
        { days: 1, hours: 8 }
      end
    end

    def round_to_quarters(total_time_in_care)
      # round hourly up to quarter hours and return as decimal
      ((total_time_in_care.in_minutes / 15.0).ceil * 15 / 60.0).hours
    end

    def absences_up_to_limit
      return [] unless absences

      # todo
      # get state limit for absences + limit frequency (i.e. 5 per month)
      # .take(this_limit) of absences
    end

    def hourly_up_to_limit
      return [] unless hourly

      # todo
      # get state limit for hourly units + limit frequency (i.e. 20 per week, 1000 per approval period)
      # .take(these_limits) of hourly
    end

    def daily_up_to_limit
      return [] unless daily

      # todo
      # get state limit for daily units + limit frequency (i.e. 3 per week, 30 per approval period)
      # .take(these_limits) of daily
    end

    # OLD CODE
    # def calculate_earned_revenue
    #   revenue = 0
    #   service_days = child.service_days.for_month(date)
    #   absence_days, attendance_days = service_days.partition do |service_day|
    #     service_day.attendances.absences.any?
    #   end
    #   if absence_days
    #     absences, covid_absences = absence_days.map do |absence_day|
    #       absence_day.absences.order(total_time_in_care: :desc).partition do |absence|
    #         absence.absence == 'absence'
    #       end
    #     end
    #     absences&.take(5)&.each { |absence| revenue += (get_rate(absence) * absence.total_time_in_care) }
    #     covid_absences&.each { |absence| revenue += (get_rate(absence) * absence.total_time_in_care) }
    #   end
    #   attendance_days.each do |attendance_day|
    #     first_attendance = attendance_day.attendances.min_by(&:check_in)
    #     revenue += (get_rate(first_attendance) * attendance_day.duration)
    #   end
    #   revenue
    # end

    # # round hourly to quarters

    # def get_rate(attendance)
    #   NebraskaRate
    #     .active_on_date(attendance.check_in)
    #     .where(school_age: attendance.child_approval.enrolled_in_school || false)
    #     .where('max_age >= ? OR max_age IS NULL', attendance.child.age_in_months(attendance.check_in))
    #     .where(region: ne_region(attendance))
    #     .where(license_type: attendance.child.business.license_type)
    #     .where(accredited_rate: attendance.child.business.accredited)
    #     .order_max_age.first.amount
    # end

    # def ne_region(attendance)
    #   %w[Lancaster Dakota Douglas Sarpy].include?(attendance.child.business.county) ? 'LDDS' : 'Other'
    # end
  end
end
