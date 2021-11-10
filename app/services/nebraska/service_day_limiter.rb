# frozen_string_literal: true

module Nebraska
  # Returns array of service days limited by the passed limit class
  class ServiceDayLimiter
    attr_reader :date, :limit_class, :service_days

    def initialize(date:, limit_class:, service_days:)
      @date = (date || Time.current).in_time_zone(service_days.first.child.timezone)
      @limit_class = limit_class
      @service_days = service_days
    end

    def call
      limited_list_of_service_days
    end

    private

    def limited_list_of_service_days
      days = limit_class.reject_frequency(service_days)
      limit_class.reject_amount(days)
    end
  end
end
