# frozen_string_literal: true

# Service to update a service day's calculated fields
# when relevant data changes
class ServiceDayCalculator
  attr_reader :service_day

  def initialize(service_day:)
    @service_day = service_day
  end

  def call
    if @service_day.absence_type == 'absence_on_unscheduled_day'
      @service_day.update(total_time_in_care: 8.hours)
    else
      update_calculations
    end
  end

  private

  def update_calculations
    Nebraska::ServiceDayCalculator.new(service_day: service_day).call if service_day.child.state == 'NE'
    Illinois::ServiceDayCalculator.new(service_day: service_day).call if service_day.child.state == 'IL'
  end
end
