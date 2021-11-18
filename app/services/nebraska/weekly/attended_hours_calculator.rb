# frozen_string_literal: true

module Nebraska
  module Weekly
    # Service to calculate full days used in Nebraska by specific kids
    class AttendedHoursCalculator
      attr_reader :child, :filter_date

      def initialize(child:, filter_date:)
        @child = child
        @filter_date = filter_date
      end

      def call
        calculate_weekly_hours_attended
      end

      private

      def calculate_weekly_hours_attended
        weekly_hours.seconds.in_hours.round(1)
      end

      def weekly_hours
        # since this is an actual count of attended *hours* regardless of the classification
        # of the service day, we're summing actual time in care rather than using only hourly attendances
        absences_for_this_week = absences_before_this_week
        child.service_days.for_week(filter_date).reduce(0) do |sum, service_day|
          if service_day.absence?
            absences_for_this_week += 1
            # up to 5 absences a *MONTH* should count towards hours attended this week
            next sum if absences_for_this_week > 5
          end

          sum + service_day.total_time_in_care
        end
      end

      def absences
        child.service_days.standard_absences
      end

      def absences_before_this_week
        absences.for_month(filter_date).length - absences.for_week(filter_date).length
      end
    end
  end
end
