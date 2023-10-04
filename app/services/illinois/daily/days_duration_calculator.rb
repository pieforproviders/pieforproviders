# frozen_string_literal: true

module Illinois
  module Daily
    # Calculate full and part days attended for a given service day
    class DaysDurationCalculator
      attr_reader :total_time_in_care, :times

      def initialize(total_time_in_care:)
        @total_time_in_care = total_time_in_care
      end

      def call
        calculate_days
      end

      private

      def calculate_days
        {
          full_time:,
          part_time:
        }
      end

      def full_time
        return 0 if total_time_in_care <= 5.hours
        return 1 if total_time_in_care > 5.hours && total_time_in_care < 12.hours
        return 2 if total_time_in_care >= 17.hours

        1 if total_time_in_care >= 12.hours && total_time_in_care < 17.hours
      end

      def part_time
        return 0 if zero_part_time?
        return 1 if total_time_in_care <= 5.hours

        1 if total_time_in_care >= 12.hours && total_time_in_care < 17.hours
      end

      def zero_part_time?
        total_time_in_care.zero? ||
          total_time_in_care >= 17.hours ||
          (total_time_in_care > 5.hours && total_time_in_care < 12.hours)
      end
    end
  end
end
