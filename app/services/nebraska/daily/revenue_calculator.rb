# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate earned revenue for a given service day
    class RevenueCalculator
      attr_reader :business, :child, :child_approval, :date, :total_time_in_care

      def initialize(business:, child:, child_approval:, date:, total_time_in_care:)
        @business = business
        @child = child
        @child_approval = child_approval
        @date = date
        @total_time_in_care = total_time_in_care
      end

      def call
        calculate_earned_revenue
      end

      private

      def calculate_earned_revenue
        child_approval&.special_needs_rate ? ne_special_needs_revenue : ne_base_revenue
      end

      def ne_hours
        Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: total_time_in_care).call
      end

      def ne_days
        Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: total_time_in_care).call
      end

      def ne_special_needs_revenue
        (ne_hours * child_approval.special_needs_hourly_rate) +
          (ne_days * child_approval.special_needs_daily_rate)
      end

      def ne_base_revenue
        (ne_hours * ne_hourly_rate * business.ne_qris_bump) +
          (ne_days * ne_daily_rate * business.ne_qris_bump)
      end

      def ne_hourly_rate
        ne_rates.hourly.first&.amount || 0
      end

      def ne_daily_rate
        ne_rates.daily.first&.amount || 0
      end

      def ne_rates
        active_child_rates
          .where(region: ne_region)
          .where(license_type: business.license_type)
          .where(accredited_rate: business.accredited)
          .order_max_age
      end

      def active_child_rates
        NebraskaRate
          .active_on(date)
          .where(school_age: child_approval&.enrolled_in_school || false)
          .where('max_age >= ? OR max_age IS NULL', child.age_in_months(date))
      end

      # rubocop:disable Metrics/MethodLength
      def ne_region
        if business.license_type == 'license_exempt_home'
          if %w[Lancaster Dakota].include?(business.county)
            'Lancaster-Dakota'
          elsif %(Douglas Sarpy).include?(business.county)
            'Douglas-Sarpy'
          else
            'Other'
          end
        elsif business.license_type == 'family_in_home'
          'All'
        else
          %w[Lancaster Dakota Douglas Sarpy].include?(business.county) ? 'LDDS' : 'Other'
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
