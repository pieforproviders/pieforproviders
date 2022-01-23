# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate earned revenue for a given service day
    class RevenueCalculator
      attr_reader :business, :child, :child_approval, :date, :total_time_in_care, :rates

      def initialize(child_approval:, date:, total_time_in_care:, rates:)
        @child_approval = child_approval
        @child = child_approval.child
        @business = child.business
        @date = date
        @rates = rates
        @total_time_in_care = total_time_in_care
      end

      def call
        calculate_earned_revenue
      end

      private

      def calculate_earned_revenue
        child_approval&.special_needs_rate ? ne_special_needs_revenue : ne_base_revenue
      end

      def hours
        Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: total_time_in_care).call
      end

      def days
        Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: total_time_in_care).call
      end

      def ne_special_needs_revenue
        (hours * child_approval.special_needs_hourly_rate) +
          (days * child_approval.special_needs_daily_rate)
      end

      def ne_base_revenue
        (hours * hourly_rate * business.ne_qris_bump) +
          (days * daily_rate * business.ne_qris_bump)
      end

      def hourly_rate
        rates.find do |rate|
          rate.rate_type == 'hourly' && rate.effective_on <= date && (rate.expires_on.nil? || rate.expires_on > date)
        end&.amount || 0
      end

      def daily_rate
        rates.find do |rate|
          rate.rate_type == 'daily' && rate.effective_on <= date && (rate.expires_on.nil? || rate.expires_on > date)
        end&.amount || 0
      end
    end
  end
end
