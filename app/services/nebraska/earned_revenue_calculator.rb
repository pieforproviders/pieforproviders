# frozen_string_literal: true

module Nebraska
  # Service to calculate a service day's total time in care
  # based on its attendances' accumulated time in care and Nebraska Rules
  class EarnedRevenueCalculator < EarnedRevenueCalculator
    attr_reader :business, :child, :child_approval, :service_day

    def initialize(service_day:)
      super
      @child = service_day.child
      @business = child.business
      @child_approval = child.active_child_approval(service_day.date)
    end

    def call
      calculate_earned_revenue
    end

    private

    def calculate_earned_revenue
      service_day.update!(earned_revenue: earned_revenue)
    end

    def earned_revenue
      return 0 unless child_approval && service_day.date && service_day.total_time_in_care

      Nebraska::Daily::RevenueCalculator.new(
        child_approval: child_approval,
        date: service_day.date,
        total_time_in_care: service_day.total_time_in_care,
        rates: rates
      ).call
    end

    def rates
      NebraskaRate.for_case(
        service_day.date,
        child_approval&.enrolled_in_school || false,
        child.age_in_months(service_day.date),
        business
      )
    end
  end
end
