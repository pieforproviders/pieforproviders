# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate full days attended for a given service day
    class DaysDurationCalculator
      attr_reader :total_time_in_care
      attr_reader :filter_date

      def initialize(total_time_in_care:, filter_date: Date.today)
        @total_time_in_care = total_time_in_care
        @filter_date = filter_date
      end

      def call
        calculate_days
      end

      private

      def calculate_days
        control_date = Date.new(2023,7,1)
        return total_time_in_care > 5.hours + 45.minutes ? 1 : 0 if filter_date < control_date
        return total_time_in_care >= 5.hours ? 1 : 0 if filter_date >= control_date
      end
    end
  end
end
