# frozen_string_literal: true

module Nebraska
  # A service day with its earned revenue and duration calculated
  # for use in the dashboard endpoint
  class CalculatedServiceDay
    attr_reader :service_day, :total_time_in_care, :earned_revenue, :date

    def initialize(service_day:)
      @service_day = service_day
      @total_time_in_care = total_time_in_care
      @earned_revenue = earned_revenue
      @date = service_day.date.to_date
    end

    def total_time_in_care
      if service_day.attendances.present?
        service_day.attendances&.sum(&:total_time_in_care)
      else
        service_day.child.schedules.active_on(service_day.date).where(weekday: service_day.date.wday).first.duration
      end
    end

    def earned_revenue
      Nebraska::Daily::RevenueCalculator.new(
        business: service_day.child.business,
        child: service_day.child,
        child_approval: service_day.child.active_child_approval(service_day.date),
        date: service_day.date,
        total_time_in_care: total_time_in_care
      ).call
    end
  end
end
