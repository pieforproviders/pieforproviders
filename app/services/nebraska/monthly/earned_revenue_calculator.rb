# frozen_string_literal: true

module Nebraska
  module Monthly
    # Calculate earned revenue for a child on a given date for the month
    class EarnedRevenueCalculator
      attr_reader :child, :filter_date

      def initialize(child:, filter_date:)
        @child = child
        @filter_date = filter_date
      end

      def call
        calculate_earned_revenue
      end

      private

      def calculate_earned_revenue
        absence_revenue + attendance_revenue
      end

      def absence_revenue
        absences = child.service_days.standard_absences.for_month(filter_date).order(total_time_in_care: :desc)
        covid_absences = child.service_days.covid_absences.for_month(filter_date).order(total_time_in_care: :desc)
        # only five absences are allowed per month in Nebraska
        absences.take(5).sum(&:earned_revenue) + covid_absences.sum(&:earned_revenue)
      end

      def attendance_revenue
        non_absences = child.service_days&.non_absences&.for_month(filter_date)
        return 0 unless non_absences

        non_absences.sum(&:earned_revenue)
      end
    end
  end
end
