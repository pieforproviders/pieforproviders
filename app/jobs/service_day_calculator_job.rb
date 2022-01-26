# frozen_string_literal: true

# Job to calculate fields on ServiceDay model
class ServiceDayCalculatorJob < ApplicationJob
  def perform(service_day_id)
    service_day = ServiceDay.find_by(id: service_day_id)
    return unless service_day

    ServiceDayCalculator.new(service_day: service_day).call
  end
end
