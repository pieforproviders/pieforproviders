# frozen_string_literal: true

module Nebraska
  # Service to update a service day's calculated fields
  # when relevant data changes
  class ServiceDayCalculator
    attr_reader :service_day

    def initialize(service_day:)
      @service_day = service_day
    end

    def call
      update_calculations
    end

    private

    def update_calculations
      TotalTimeInCareCalculator.new(service_day: service_day).call
      EarnedRevenueCalculator.new(service_day: service_day).call
    end
  end
end
