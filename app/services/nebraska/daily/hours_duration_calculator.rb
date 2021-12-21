# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate hours attended for a given service day
    class HoursDurationCalculator
      attr_reader :total_time_in_care

      def initialize(total_time_in_care:)
        @total_time_in_care = total_time_in_care
      end

      def call
        calculate_rounded_hours
      end

      private

      def calculate_rounded_hours
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

      def hourly?
        total_time_in_care.between?(0.hours, 5.hours + 45.minutes)
      end

      def daily_plus_hourly?
        total_time_in_care.between?(10.hours + 1.minute, 18.hours)
      end

      def daily_plus_hourly_max?
        total_time_in_care > 18.hours
      end
    end
  end
end
