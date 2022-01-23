# frozen_string_literal: true

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
    Nebraska::ServiceDayCalculator.new(service_day: service_day).call if service_day.child.state == 'NE'
  end
end
