# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate full days attended for a given service day
    class DurationCalculator
      attr_reader :total_time_in_care

      def initialize(total_time_in_care:)
        @total_time_in_care = total_time_in_care
      end

      def call
        calculate
      end

      def hourly?
        total_time_in_care.between?(0.hours, 5.hours + 59.minutes)
      end

      def daily?
        total_time_in_care.between?(6.hours, 9.hours + 59.minutes)
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
