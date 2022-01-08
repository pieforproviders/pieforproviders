# frozen_string_literal: true

module Nebraska
  # A service day with its earned revenue and duration calculated
  # for use in the dashboard endpoint
  class CalculatedServiceDay
    attr_reader :service_day, :child_approval, :rates, :schedule

    def initialize(service_day:, child_approvals:, rates:, schedule: nil)
      @service_day = service_day
      @schedule = schedule
      @child_approval = child_approval_for_day(child_approvals)
      @rates = rates
    end

    def total_time_in_care
      service_day.total_time_in_care(schedule_duration: schedule&.duration)
    end

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
      child_approvals.select do |child_approval|
        child_approval.effective_on <= service_day.date &&
          (child_approval.expires_on.nil? || child_approval.expires_on > service_day.date)
      end.first
    end
  end
end
