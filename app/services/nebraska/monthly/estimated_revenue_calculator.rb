# frozen_string_literal: true

module Nebraska
  module Monthly
    # Calculate estimated revenue for a child on a given date for the month
    class EstimatedRevenueCalculator
      attr_reader :child, :child_approval, :filter_date, :schedules, :service_days

      def initialize(child:, child_approval:, filter_date:)
        @child = child
        @child_approval = child_approval
        @filter_date = filter_date
        @schedules = child.schedules
        @service_days = child.service_days
      end

      def call
        calculate_estimated_revenue
      end

      private

      def calculate_estimated_revenue
        (Nebraska::Monthly::EarnedRevenueCalculator.new(
          service_days: service_days,
          filter_date: filter_date
        ).call + remaining_scheduled_revenue)
      end

      def remaining_scheduled_revenue
        (filter_date.to_date..filter_date.to_date.at_end_of_month).reduce(0) do |sum, date|
          next sum if schedule(date: date).blank?
          next sum if skip_today(date: date)

          sum + scheduled_revenue(date: date)
        end
      end

      def skip_today(date:)
        # if there's already an attendance on the filter date,
        # and the date we're passing is the filter date,
        # then skip today
        service_days.for_day(filter_date).present? && date.to_date == filter_date.to_date
      end

      def scheduled_revenue(date:)
        Nebraska::Daily::RevenueCalculator.new(business: child.business,
                                               child: child,
                                               child_approval: child_approval,
                                               date: date,
                                               total_time_in_care: schedule(date: date).duration).call
      end

      def schedule(date:)
        schedules.active_on(date).select { |schedule| schedule.weekday == date.wday }.first
      end
    end
  end
end

# TODO: currently creating a ServiceDay like this will generate a bunch that turn up in the scope, I believe.
