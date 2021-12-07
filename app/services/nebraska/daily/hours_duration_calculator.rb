# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate hours attended for a given service day
    class HoursDurationCalculator < DurationCalculator
      private

      def calculate
        (adjusted_duration.in_minutes / 15.0).ceil * 15 / 60.0
      end

      def adjusted_duration
        if hourly?
          total_time_in_care
        elsif daily_plus_hourly?
          total_time_in_care - 10.hours
        elsif daily_plus_hourly_max?
          8.hours
        else
          0.minutes
        end
      end
    end
  end
end
