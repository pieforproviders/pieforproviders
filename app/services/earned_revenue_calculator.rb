# frozen_string_literal: true

# Service to calculate a service day's earned_revenue
# based on its total_time_in_care and rate
class EarnedRevenueCalculator
  attr_reader :service_day

  def initialize(service_day:)
    @service_day = service_day
  end

  def call
    calculate_earned_revenue
  end

  private

  def calculate_earned_revenue
    Nebraska::EarnedRevenueCalculator.new(service_day: service_day).call if service_day.child.state == 'NE'
  end
end
