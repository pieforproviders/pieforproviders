# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate full days attended for a given service day
    class DaysDurationCalculator < DurationCalculator
      private

      def calculate
        total_time_in_care > 5.hours + 45.minutes ? 1 : 0
      end
    end
  end
end
