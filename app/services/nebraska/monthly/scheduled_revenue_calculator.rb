# frozen_string_literal: true

module Nebraska
  module Monthly
    # Calculate scheduled revenue for a child on a given date for the month
    class ScheduledRevenueCalculator
      attr_reader :child, :filter_date

      def initialize(child:, filter_date:)
        @child = child
        @filter_date = filter_date
      end

      def call
        calculate_scheduled_revenue
      end

      private

      def calculate_scheduled_revenue
        (filter_date.to_date.at_beginning_of_month..filter_date.to_date.at_end_of_month).reduce(0) do |sum, date|
          next sum if schedule(date: date).blank?

          sum + scheduled_revenue(date: date)
        end
      end

      def scheduled_revenue(date:)
        Nebraska::Daily::RevenueCalculator.new(business: child.business,
                                               child: child,
                                               date: date,
                                               total_time_in_care: schedule(date: date).duration).call
      end

      def schedule(date:)
        child.schedules.active_on_date(date).select { |schedule| schedule.weekday == date.wday }.first
      end
    end
  end
end

# TODO: currently creating a ServiceDay like this will generate a bunch that turn up in the scope, I believe.
