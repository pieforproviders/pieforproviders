# frozen_string_literal: true

module Nebraska
  # A service day with its earned revenue and duration calculated
  # for use in the dashboard endpoint
  class CalculatedServiceDay
    attr_reader :service_day, :child_approval, :rates

    def initialize(service_day:, child_approvals:, rates:)
      @service_day = service_day
      @child_approval = child_approval_for_day(child_approvals)
      @rates = rates
    end

    delegate :total_time_in_care, to: :service_day

    def earned_revenue
      return 0 unless child_approval && service_day.date && total_time_in_care

      Nebraska::Daily::RevenueCalculator.new(
        child_approval: child_approval,
        date: service_day.date,
        total_time_in_care: total_time_in_care,
        rates: rates
      ).call
    end

    private

    def child_approval_for_day(child_approvals)
      child_approvals.find do |child_approval|
        child_approval.effective_on <= service_day.date &&
          (child_approval.expires_on.nil? || child_approval.expires_on > service_day.date)
      end
    end
  end
end
