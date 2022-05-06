# frozen_string_literal: true

# Job to calculate fields on ServiceDay model
class ServiceDayCalculatorJob < ApplicationJob
  def perform(service_day)
    return unless service_day

    ServiceDayCalculator.new(service_day: service_day).call
  end
end
