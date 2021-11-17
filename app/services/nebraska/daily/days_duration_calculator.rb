# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate full days attended for a given service day
    class DaysDurationCalculator
      attr_reader :total_time_in_care

      def initialize(total_time_in_care:)
        @total_time_in_care = total_time_in_care
      end

      def call
        calculate_days
      end

      private

      def calculate_days
        total_time_in_care > 5.hours + 45.minutes ? 1 : 0
      end
    end
  end
end
