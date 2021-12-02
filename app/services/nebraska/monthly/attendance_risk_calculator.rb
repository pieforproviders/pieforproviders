# frozen_string_literal: true

module Nebraska
  module Monthly
    # Calculate attendance risk for a child on a given date
    class AttendanceRiskCalculator
      attr_reader :child, :filter_date, :scheduled_revenue, :estimated_revenue

      def initialize(child:, filter_date:, scheduled_revenue:, estimated_revenue:)
        @child = child
        @filter_date = filter_date
        @scheduled_revenue = scheduled_revenue
        @estimated_revenue = estimated_revenue
      end

      def call
        calculate_risk
      end

      private

      def calculate_risk
        return 'not_enough_info' if filter_date <= minimum_days_to_calculate

        ratio = (estimated_revenue.to_f - scheduled_revenue.to_f) / scheduled_revenue.to_f
        risk_ratio_label(ratio)
      end

      def risk_ratio_label(ratio)
        if ratio <= -0.2
          'at_risk'
        elsif ratio > -0.2 && ratio <= 0.2
          'on_track'
        else
          'ahead_of_schedule'
        end
      end

      def minimum_days_to_calculate
        filter_date.in_time_zone(child.timezone).at_beginning_of_month + 9.days
      end
    end
  end
end
