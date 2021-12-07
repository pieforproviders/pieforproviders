# frozen_string_literal: true

module Nebraska
  module Daily
    # Calculate earned revenue for a given service day
    class RevenueCalculator
      attr_reader :accredited,
                  :active_rates,
                  :age,
                  :business,
                  :child,
                  :child_approval,
                  :county,
                  :date,
                  :days,
                  :enrolled_in_school,
                  :hours,
                  :license_type,
                  :qris_bump,
                  :special_needs_rate,
                  :special_needs_hourly_rate,
                  :special_needs_daily_rate

      def initialize(business:, child:, child_approval:, date:, days:, hours:)
        @business = business
        @child = child
        @child_approval = child_approval
        @date = date
        @days = days
        @hours = hours
        @accredited = business.accredited
        @age = child.age_in_months(date)
        @county = business.county
        @enrolled_in_school = child_approval&.enrolled_in_school || false
        @license_type = business.license_type
        @qris_bump = business.ne_qris_bump
        @special_needs_rate = child_approval&.special_needs_rate || false
        @special_needs_hourly_rate = child_approval&.special_needs_hourly_rate || 0
        @special_needs_daily_rate = child_approval&.special_needs_daily_rate || 0
        @active_rates = rates
      end

      def call
        calculate_earned_revenue
      end

      private

      def calculate_earned_revenue
        special_needs_rate ? special_needs_revenue : base_revenue
      end

      def special_needs_revenue
        (hours * special_needs_hourly_rate) +
          (days * special_needs_daily_rate)
      end

      def base_revenue
        (hours * hourly_rate * qris_bump) +
          (days * daily_rate * qris_bump)
      end

      def hourly_rate
        active_rates.hourly.first&.amount || 0
      end

      def daily_rate
        active_rates.daily.first&.amount || 0
      end

      def rates
        NebraskaRate
          .active_on(date)
          .where(school_age: enrolled_in_school)
          .where('max_age >= ? OR max_age IS NULL', age)
          .where(region: region)
          .where(license_type: license_type)
          .where(accredited_rate: accredited)
          .order_max_age
      end

      # rubocop:disable Metrics/MethodLength
      def region
        if license_type == 'license_exempt_home'
          if %w[Lancaster Dakota].include?(county)
            'Lancaster-Dakota'
          elsif %(Douglas Sarpy).include?(county)
            'Douglas-Sarpy'
          else
            'Other'
          end
        elsif license_type == 'family_in_home'
          'All'
        else
          %w[Lancaster Dakota Douglas Sarpy].include?(county) ? 'LDDS' : 'Other'
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
