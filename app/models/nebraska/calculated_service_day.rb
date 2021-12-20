# frozen_string_literal: true

module Nebraska
  # A service day with its earned revenue and duration calculated
  # for use in the dashboard endpoint
  class CalculatedServiceDay
    attr_reader :service_day, :schedule, :child_approval, :rates

    def initialize(service_day:, schedules:, child_approvals:, rates:)
      @service_day = service_day
      @schedule = schedule_for_day(schedules)
      @child_approval = child_approval_for_day(child_approvals)
      @rates = rates
    end

    def total_time_in_care
      service_day.attendances.presence&.sum(&:time_in_care) || schedule&.duration || 0.minutes
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

    def schedule_for_day(schedules)
      schedules.select do |schedule|
        schedule.weekday == service_day.date.wday &&
          schedule.effective_on <= service_day.date &&
          (schedule.expires_on.nil? || schedule.expires_on > service_day.date)
      end.first
    end

    def child_approval_for_day(child_approvals)
      child_approvals.select do |child_approval|
        child_approval.effective_on <= service_day.date &&
          (child_approval.expires_on.nil? || child_approval.expires_on > service_day.date)
      end.first
    end
  end
end
