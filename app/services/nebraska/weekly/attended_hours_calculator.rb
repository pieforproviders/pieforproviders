# frozen_string_literal: true

module Nebraska
  module Weekly
    # Service to calculate full days used in Nebraska by specific kids
    class AttendedHoursCalculator
      attr_reader :service_days, :absences, :service_days_this_week, :filter_date, :child_approvals, :rates

      def initialize(service_days:, filter_date:, child_approvals:, rates:)
        @service_days = service_days
        @filter_date = filter_date
        @child_approvals = child_approvals
        @rates = rates
        @absences = service_day_absences
        @service_days_this_week = service_days_for_week
      end

      def call
        calculate_weekly_hours_attended
      end

      private

      def service_day_absences
        service_days.select do |service_day|
          service_day.attendances.any? do |attendance|
            attendance.absence == 'absence'
          end
        end
      end

      def service_days_for_week
        service_days.select do |service_day|
          service_day.date.between?(filter_date.at_beginning_of_week(:sunday), filter_date.at_end_of_week(:saturday))
        end
      end

      def calculate_weekly_hours_attended
        weekly_hours.seconds.in_hours.round(1)
      end

      def weekly_hours
        # since this is an actual count of attended *hours* regardless of the classification
        # of the service day, we're summing actual time in care rather than using only hourly attendances
        absences_for_this_week = absences_before_this_week

        days = service_days_this_week.map do |service_day|
          if service_day.absence?
            absences_for_this_week += 1
            # up to 5 absences a *MONTH* should count towards hours attended this week
            next if absences_for_this_week > 5
          end

          Nebraska::CalculatedServiceDay.new(service_day: service_day,
                                             child_approvals: child_approvals,
                                             rates: rates)
        end
        days.reduce(0) do |sum, service_day|
          sum + (service_day&.total_time_in_care.presence || 0)
        end
      end

      def absences_before_this_week
        absences.length - absences.select do |service_day|
          service_day.date.between?(filter_date.at_beginning_of_week(:sunday), filter_date.at_end_of_week(:saturday))
        end.length
      end
    end
  end
end
